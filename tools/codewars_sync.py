#!/usr/bin/env python3
"""Выгрузка решённых кат с Codewars в репозиторий.

Алгоритм:
  1. авторизация на codewars.com (email/пароль или cookie из браузера);
  2. обход https://www.codewars.com/users/<user>/completed_solutions со всеми страницами;
  3. для каждой каты берём название, сложность и код каждого языка;
  4. описание и ссылку берём из API Codewars (то же, что на странице каты);
  5. каты, которые уже есть в репозитории (по ссылке или по названию), пропускаем.

Файлы кладутся в <язык>/[<библиотека>/][N kyu] Название.<расширение>.

Запуск:
  python tools/codewars_sync.py              # синхронизировать
  python tools/codewars_sync.py --dry-run    # только показать, что будет создано
  python tools/codewars_sync.py --html page.html --dry-run   # без логина, по сохранённой странице

Настройки берутся из .env в корне репозитория (см. .env.example).
"""
from __future__ import annotations

import argparse
import html
import json
import logging
import os
import re
import sys
import time
import warnings
from dataclasses import dataclass, field
from pathlib import Path

warnings.filterwarnings('ignore', module='requests')  # несовпадение версий urllib3/chardet
import requests  # noqa: E402
from bs4 import BeautifulSoup

BASE_URL = 'https://www.codewars.com'
REPO_ROOT = Path(__file__).resolve().parent.parent
DEBUG_DIR = REPO_ROOT / '.debug'
USER_AGENT = ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/140.0 Safari/537.36')

KATA_ID_RE = re.compile(r'codewars\.com/kata/([0-9a-f]{24})')
# Ссылка на кату в заголовке решения: на сайте относительная (/kata/<id>), в сохранённой странице — полная
KATA_HREF_RE = re.compile(r'/kata/([0-9a-f]{24})/?$')
# Папки, которые не относятся к решениям
IGNORED_DIRS = {'tools'}

log = logging.getLogger('codewars')


@dataclass(frozen=True)
class Lang:
    folder: str
    ext: str
    comment: str


# id языка на Codewars -> папка, расширение, префикс комментария
LANGS = {
    'python': Lang('python/pure', '.py', '#'),
    'shell': Lang('shell', '.sh', '#'),
    'sql': Lang('sql', '.sql', '--'),
    'go': Lang('go', '.go', '//'),
    'cpp': Lang('c++', '.cpp', '//'),
    'c': Lang('c', '.c', '//'),
    'csharp': Lang('c#', '.cs', '//'),
    'java': Lang('java', '.java', '//'),
    'javascript': Lang('javascript', '.js', '//'),
    'typescript': Lang('typescript', '.ts', '//'),
    'kotlin': Lang('kotlin', '.kt', '//'),
    'rust': Lang('rust', '.rs', '//'),
    'swift': Lang('swift', '.swift', '//'),
    'scala': Lang('scala', '.scala', '//'),
    'dart': Lang('dart', '.dart', '//'),
    'php': Lang('php', '.php', '//'),
    'ruby': Lang('ruby', '.rb', '#'),
    'r': Lang('r', '.r', '#'),
    'julia': Lang('julia', '.jl', '#'),
    'elixir': Lang('elixir', '.ex', '#'),
    'powershell': Lang('powershell', '.ps1', '#'),
    'haskell': Lang('haskell', '.hs', '--'),
    'lua': Lang('lua', '.lua', '--'),
    'nasm': Lang('nasm', '.asm', ';'),
}
PANDAS = Lang('python/pandas', '.ipynb', '#')

LANG_ALIASES = {
    'py': 'python', 'python3': 'python', 'sh': 'shell', 'bash': 'shell',
    'c++': 'cpp', 'js': 'javascript', 'ts': 'typescript', 'golang': 'go',
    'postgres': 'sql', 'postgresql': 'sql', 'rb': 'ruby', 'cs': 'csharp', 'c#': 'csharp',
}


def norm_lang(name: str) -> str:
    name = name.strip().lower()
    return LANG_ALIASES.get(name, name)


def norm_name(name: str) -> str:
    """Название без регистра, пробелов и пунктуации — для поиска уже сохранённых кат."""
    return re.sub(r'[\W_]+', '', name.lower())


def safe_filename(name: str) -> str:
    name = re.sub(r'\s*[/\\]\s*', '_', name)
    name = re.sub(r'[:<>"|?*\x00-\x1f]', '', name)
    name = ' '.join(name.split()).rstrip('. ')
    return name or 'untitled'


# ---------------------------------------------------------------------------
# Решения со страницы completed_solutions

@dataclass
class Solution:
    kata_id: str
    name: str
    rank: str | None
    language: str
    codes: list[str] = field(default_factory=list)

    @property
    def url(self) -> str:
        return f'{BASE_URL}/kata/{self.kata_id}'

    @property
    def is_pandas(self) -> bool:
        return self.language == 'python' and any(
            re.search(r'^\s*(import|from)\s+pandas\b', code, re.M) for code in self.codes)

    @property
    def lang(self) -> Lang:
        if self.is_pandas:
            return PANDAS
        return LANGS.get(self.language, Lang(self.language, '.txt', '#'))

    @property
    def title(self) -> str:
        return f'[{self.rank or "beta"}] {self.name} ({self.language})'


def parse_solutions_page(page_html: str) -> tuple[list[Solution], int | None]:
    """Решения со страницы (или её фрагмента) и номер следующей страницы."""
    soup = BeautifulSoup(page_html, 'html.parser')
    solutions = []
    for item in soup.select('div.list-item-solutions'):
        title = item.select_one('.item-title')
        link = title and title.find('a', href=KATA_HREF_RE)
        if not link:
            continue
        kata_id = KATA_HREF_RE.search(link['href']).group(1)
        name = ' '.join(link.get_text().split())
        rank_el = title.select_one('.inner-small-hex span')
        rank = rank_el.get_text(strip=True) if rank_el else None

        by_lang: dict[str, list[str]] = {}
        for code in item.select('pre code[data-language]'):
            by_lang.setdefault(code['data-language'].lower(), []).append(code.get_text().rstrip())
        for language, codes in by_lang.items():
            solutions.append(Solution(kata_id, name, rank, language, codes))

    marker = soup.select_one('.js-infinite-marker[data-page]')
    next_page = int(marker['data-page']) if marker else None
    return solutions, next_page


def parse_total_count(page_html: str) -> int | None:
    m = re.search(r'Completed \((\d+)\)', page_html)
    return int(m.group(1)) if m else None


def parse_current_user(page_html: str) -> str | None:
    m = re.search(r'const currentUser = JSON\.parse\("((?:[^"\\]|\\.)*)"\)', page_html)
    if not m:
        return None
    try:
        return json.loads(json.loads(f'"{m.group(1)}"')).get('username')
    except (ValueError, AttributeError):
        return None


def merge_solutions(target: dict[tuple[str, str], Solution], solutions: list[Solution]) -> int:
    """Добавляет решения, склеивая дубли; возвращает число новых."""
    added = 0
    for sol in solutions:
        key = (sol.kata_id, sol.language)
        if key in target:
            target[key].codes.extend(c for c in sol.codes if c not in target[key].codes)
        else:
            target[key] = sol
            added += 1
    return added


# ---------------------------------------------------------------------------
# HTTP и авторизация

class AuthError(Exception):
    pass


class Codewars:
    def __init__(self, delay: float):
        self.delay = delay
        self.session = requests.Session()
        self.session.headers['User-Agent'] = USER_AGENT
        self._last_request = 0.0

    def request(self, method: str, url: str, **kwargs) -> requests.Response:
        kwargs.setdefault('timeout', 30)
        for attempt in range(1, 6):
            pause = self._last_request + self.delay - time.monotonic()
            if pause > 0:
                time.sleep(pause)
            self._last_request = time.monotonic()
            try:
                resp = self.session.request(method, url, **kwargs)
            except requests.RequestException as e:
                wait = 2 ** attempt
                log.warning('Сетевая ошибка (%s), повтор через %d с...', e, wait)
                time.sleep(wait)
                continue
            if resp.status_code == 429 or resp.status_code >= 500:
                wait = int(resp.headers.get('Retry-After') or 0) or 2 ** attempt
                log.warning('HTTP %d на %s, повтор через %d с...', resp.status_code, url, wait)
                time.sleep(wait)
                continue
            return resp
        raise RuntimeError(f'Не удалось получить {url}')

    def get(self, url: str, **kwargs) -> requests.Response:
        return self.request('GET', url, **kwargs)

    def use_cookie(self, cookie: str) -> None:
        """Строка Cookie из DevTools ("a=1; b=2") или просто значение _session_id."""
        if '=' not in cookie:
            cookie = f'_session_id={cookie}'
        for part in cookie.split(';'):
            key, sep, value = part.strip().partition('=')
            if sep:
                self.session.cookies.set(key, value, domain='www.codewars.com')

    def login(self, email: str, password: str) -> None:
        resp = self.get(f'{BASE_URL}/users/sign_in')
        token_el = BeautifulSoup(resp.text, 'html.parser').select_one(
            'form#new_user input[name=authenticity_token]')
        if not token_el:
            raise AuthError('Не нашёл форму входа на странице /users/sign_in')
        resp = self.request('POST', f'{BASE_URL}/users/sign_in', data={
            'utf8': '✓',
            'authenticity_token': token_el['value'],
            'user[email]': email,
            'user[password]': password,
            'user[remember_me]': 'true',
        }, headers={'Referer': f'{BASE_URL}/users/sign_in', 'Origin': BASE_URL})
        if parse_current_user(resp.text) is None and '/users/sign_in' in resp.url:
            raise AuthError('Codewars не принял email/пароль')

    def fetch_solutions(self, user: str) -> list[Solution]:
        url = f'{BASE_URL}/users/{user}/completed_solutions'
        first = self.get(url)
        current = parse_current_user(first.text)
        if current is None:
            raise AuthError('Не авторизованы: Codewars показывает страницу гостю')
        if current.lower() != user.lower():
            log.warning('Вошли как %s, а выгружаем решения %s', current, user)
        log.info('Вошли как %s', current)

        total = parse_total_count(first.text)
        log.info('Загружаю список решений%s', f' (кат на Codewars: {total})' if total else '')

        found: dict[tuple[str, str], Solution] = {}
        pages = [('исходная', first.text)]
        fetched: set[int] = set()
        idle = 0  # сколько страниц подряд не дали ничего нового
        while True:
            label, page_html = pages[-1]
            solutions, next_page = parse_solutions_page(page_html)
            added = merge_solutions(found, solutions)
            katas = len({kata_id for kata_id, _ in found})
            log.info('  страница %s: +%d решений, всего кат %d%s',
                     label, added, katas, f'/{total}' if total else '')
            idle = 0 if added else idle + 1
            # Первая страница может прийти пустой, только с маркером подгрузки — идём дальше по нему
            if next_page is None or next_page in fetched or idle >= 2:
                break
            fetched.add(next_page)
            pages.append((str(next_page + 1), self.get(
                url, params={'page': next_page}, headers={'X-Requested-With': 'XMLHttpRequest'}).text))

        if not found:
            DEBUG_DIR.mkdir(exist_ok=True)
            for n, (label, page_html) in enumerate(pages, 1):
                (DEBUG_DIR / f'completed_solutions_{n}.html').write_text(page_html, encoding='utf-8')
            log.error('На странице решений не нашлось ни одного решения. Полученный HTML сохранён в %s '
                      '— по нему можно понять, как Codewars отдаёт список', DEBUG_DIR)
        return list(found.values())

    def fetch_kata(self, kata_id: str) -> dict | None:
        resp = self.get(f'{BASE_URL}/api/v1/code-challenges/{kata_id}')
        if resp.status_code == 404:
            return None
        resp.raise_for_status()
        return resp.json()


# ---------------------------------------------------------------------------
# Описание: markdown Codewars -> текст для нужного языка

FENCE_RE = re.compile(r'^\s*(`{3,}|~{3,})(.*)$')
COND_RE = re.compile(r'^(if|if-not)\s*:\s*(.+)$', re.I)


@dataclass
class CodeBlock:
    info: str
    body: list[str]
    open_line: str
    close_line: str

    @property
    def language(self) -> str:
        words = self.info.split()
        return norm_lang(words[0]) if words else ''


def filter_markdown(md: str, language: str) -> list[str | CodeBlock]:
    """Разбирает описание: оставляет блоки if:/if-not: и варианты кода только для `language`."""
    lines = md.replace('\r\n', '\n').replace('\r', '\n').split('\n')
    out: list[str | CodeBlock] = []
    conditions: list[tuple[str, int, bool]] = []  # (символ ограды, длина, показывать ли)
    i = 0
    while i < len(lines):
        line = lines[i]
        visible = all(show for *_, show in conditions)
        m = FENCE_RE.match(line)
        if not m:
            if visible:
                out.append(line)
            i += 1
            continue

        fence, info = m.group(1), m.group(2).strip()
        cond = COND_RE.match(info)
        if cond:
            langs = {norm_lang(x) for x in re.split(r'[,\s]+', cond.group(2)) if x}
            show = (language in langs) == (cond.group(1).lower() == 'if')
            conditions.append((fence[0], len(fence), show))
            i += 1
            continue
        if not info and conditions and fence[0] == conditions[-1][0] and len(fence) >= conditions[-1][1]:
            conditions.pop()
            i += 1
            continue

        end = next((k for k in range(i + 1, len(lines)) if is_closing_fence(lines[k], fence)), None)
        if end is not None:
            body, close_line = lines[i + 1:end], lines[end]
        else:
            # Незакрытый блок — обычно опечатка вида "текст```": закрываем блок на этой строке
            end = next((k for k in range(i + 1, len(lines)) if lines[k].rstrip().endswith(fence)),
                       len(lines))
            body = lines[i + 1:end]
            if end < len(lines):
                body.append(lines[end].rstrip()[:-len(fence)])
            close_line = fence
        i = end + 1
        if visible:
            out.append(CodeBlock(info, body, line, close_line))
    return select_code_variants(out, language)


def is_closing_fence(line: str, fence: str) -> bool:
    m = FENCE_RE.match(line)
    return bool(m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence)
                and not m.group(2).strip())


def select_code_variants(items: list[str | CodeBlock], language: str) -> list[str | CodeBlock]:
    """Идущие подряд блоки кода на разных языках — показываем только нужный язык."""
    result: list[str | CodeBlock] = []
    i = 0
    while i < len(items):
        if not isinstance(items[i], CodeBlock):
            result.append(items[i])
            i += 1
            continue
        j = i
        while j < len(items) and isinstance(items[j], CodeBlock):
            j += 1
        group = items[i:j]
        langs = [b.language for b in group]
        if len(group) > 1 and all(langs) and len(set(langs)) > 1:
            group = [next((b for b in group if b.language == language), group[0])]
        result.extend(group)
        i = j
    return result


def items_to_markdown(items: list[str | CodeBlock]) -> str:
    lines = []
    for item in items:
        if isinstance(item, CodeBlock):
            lines += [item.open_line, *item.body, item.close_line]
        else:
            lines.append(item)
    return tidy_blank_lines('\n'.join(lines))


def tidy_blank_lines(text: str) -> str:
    text = '\n'.join(line.rstrip() for line in text.split('\n'))
    return re.sub(r'\n{3,}', '\n\n', text).strip('\n')


def markdown_text_to_plain(text: str) -> str:
    """Убирает разметку из обычного (не кодового) фрагмента markdown."""
    spans: list[str] = []

    def stash(m: re.Match) -> str:
        code = m.group(2)
        if len(code) > 1 and code.startswith(' ') and code.endswith(' '):
            code = code[1:-1]
        spans.append(code)
        return f'\x00{len(spans) - 1}\x00'

    text = re.sub(r'(`+)([^\n]+?)\1', stash, text)
    text = re.sub(r'<!--.*?-->', '', text, flags=re.S)
    text = re.sub(r'<(https?://[^>\s]+)>', r'\1', text)
    text = re.sub(r'<br\s*/?>|</br>', '\n', text, flags=re.I)
    text = re.sub(r'<li[^>]*>', '- ', text, flags=re.I)
    text = re.sub(r'</(p|div|tr|li|ul|ol|table|h\d|pre)>', '\n', text, flags=re.I)
    text = re.sub(r'</t[dh]>', ' ', text, flags=re.I)
    text = re.sub(r'</?[a-zA-Z][^>]*>', '', text)

    text = re.sub(r'^[ \t]{0,3}#{1,6}(?:[ \t]+|$)(.*?)(?:[ \t]+#+)?[ \t]*$', r'\1', text, flags=re.M)
    text = re.sub(r'^[ \t]*([-*_])(?:[ \t]*\1){2,}[ \t]*$', '', text, flags=re.M)  # --- *** ___
    text = re.sub(r'^[ \t]*=+[ \t]*$', '', text, flags=re.M)
    text = re.sub(r'^([ \t]*)>[ \t]?', r'\1', text, flags=re.M)

    text = re.sub(r'!\[([^\]]*)\]\(\s*<?([^)\s>]+)>?[^)]*\)',
                  lambda m: f'[{m.group(1) or "image"}: {m.group(2)}]', text)
    text = re.sub(r'\[([^\]]+)\]\(\s*<?([^)\s>]+)>?[^)]*\)',
                  lambda m: m.group(1) if m.group(1) == m.group(2) else f'{m.group(1)} ({m.group(2)})', text)

    text = re.sub(r'\*\*(?!\s)(.+?)(?<!\s)\*\*', r'\1', text)
    text = re.sub(r'(?<!\w)__(?!\s)(.+?)(?<!\s)__(?!\w)', r'\1', text)
    text = re.sub(r'(?<![\w*])\*(?![\s*])(.+?)(?<![\s*])\*(?![\w*])', r'\1', text)
    text = re.sub(r'(?<![\w_])_(?![\s_])(.+?)(?<![\s_])_(?![\w_])', r'\1', text)
    text = re.sub(r'~~(.+?)~~', r'\1', text)
    text = re.sub(r'\\([\\`*_{}\[\]()#+\-.!|<>~])', r'\1', text)
    text = html.unescape(text)

    return re.sub(r'\x00(\d+)\x00', lambda m: spans[int(m.group(1))], text)


def markdown_to_plain(items: list[str | CodeBlock]) -> str:
    parts: list[str] = []
    buffer: list[str] = []
    for item in items:
        if isinstance(item, CodeBlock):
            parts.append(markdown_text_to_plain('\n'.join(buffer)))
            buffer = []
            parts.append('\n'.join(item.body))
        else:
            buffer.append(item)
    parts.append(markdown_text_to_plain('\n'.join(buffer)))
    return tidy_blank_lines('\n'.join(parts))


# ---------------------------------------------------------------------------
# Файлы решений

def build_source_file(sol: Solution, description: str) -> str:
    p = sol.lang.comment
    lines = [f'{p} {sol.name}', f'{p} {sol.url}', '']
    if description:
        lines += [f'{p} {line}'.rstrip() for line in description.split('\n')]
        lines.append('')
    for n, code in enumerate(sol.codes, 1):
        if len(sol.codes) > 1:
            if n > 1:
                lines += ['', '']
            lines.append(f'{p} ---------- Solution {n} ----------')
        lines.append(code)
    return '\n'.join(lines).rstrip() + '\n'


def build_notebook(sol: Solution, description_md: str) -> str:
    def source(text: str) -> list[str]:
        lines = text.split('\n')
        return [line + '\n' for line in lines[:-1]] + [lines[-1]]

    markdown = f'__[Codewars Link]({sol.url})__\n\n# {sol.name}'
    if description_md:
        markdown += f'\n\n{description_md}'
    cells = [{'cell_type': 'markdown', 'metadata': {}, 'source': source(markdown)}]
    for code in sol.codes:
        cells.append({'cell_type': 'code', 'execution_count': None, 'metadata': {},
                      'outputs': [], 'source': source(code)})
    notebook = {
        'cells': cells,
        'metadata': {
            'kernelspec': {'display_name': 'Python 3', 'language': 'python', 'name': 'python3'},
            'language_info': {'name': 'python'},
        },
        'nbformat': 4,
        'nbformat_minor': 4,
    }
    return json.dumps(notebook, indent=1, ensure_ascii=False) + '\n'


class RepoIndex:
    """Что уже лежит в репозитории: ссылки на каты и названия файлов по папкам языков."""

    def __init__(self, root: Path):
        self.root = root
        self.ids: set[tuple[str, str]] = set()
        self.names: set[tuple[str, str]] = set()
        files = 0
        for path in root.rglob('*'):
            rel = path.relative_to(root)
            if (not path.is_file() or len(rel.parts) < 2
                    or rel.parts[0].startswith('.') or rel.parts[0] in IGNORED_DIRS):
                continue
            files += 1
            self.add(path, path.read_text(encoding='utf-8', errors='ignore'))
        log.info('В репозитории %d файлов, известно %d решений по ссылкам', files, len(self.ids))

    def add(self, path: Path, content: str) -> None:
        top = path.relative_to(self.root).parts[0]
        for kata_id in KATA_ID_RE.findall(content):
            self.ids.add((top, kata_id))
        m = re.match(r'\[[^\]]*\]\s*(.+)$', path.stem)
        if m:
            self.names.add((top, norm_name(m.group(1))))

    def contains(self, sol: Solution) -> bool:
        top = sol.lang.folder.split('/')[0]
        return (top, sol.kata_id) in self.ids or (top, norm_name(sol.name)) in self.names


def target_path(root: Path, sol: Solution) -> Path:
    lang = sol.lang
    return root / lang.folder / f'[{sol.rank or "beta"}] {safe_filename(sol.name)}{lang.ext}'


# ---------------------------------------------------------------------------

def load_env(path: Path) -> None:
    if not path.exists():
        return
    for line in path.read_text(encoding='utf-8').splitlines():
        line = line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, _, value = line.partition('=')
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def authorize(cw: Codewars) -> None:
    cookie = os.environ.get('CODEWARS_COOKIE', '').strip()
    email = os.environ.get('CODEWARS_EMAIL', '').strip()
    password = os.environ.get('CODEWARS_PASSWORD', '')
    if cookie:
        log.info('Авторизация по cookie из CODEWARS_COOKIE')
        cw.use_cookie(cookie)
    elif email and password:
        log.info('Авторизация: вход как %s', email)
        cw.login(email, password)
    else:
        raise AuthError('Заполните в .env CODEWARS_EMAIL + CODEWARS_PASSWORD или CODEWARS_COOKIE')


def main() -> int:
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, 'reconfigure'):
            stream.reconfigure(encoding='utf-8')

    parser = argparse.ArgumentParser(description='Выгрузка решений с Codewars в репозиторий')
    parser.add_argument('--user', help='ник на Codewars (по умолчанию CODEWARS_USER из .env)')
    parser.add_argument('--root', type=Path, default=REPO_ROOT, help='куда сохранять (корень репозитория)')
    parser.add_argument('--html', type=Path, nargs='+',
                        help='взять список решений из сохранённых страниц, без логина')
    parser.add_argument('--dry-run', action='store_true', help='ничего не записывать, только показать')
    parser.add_argument('--limit', type=int, help='обработать не больше N новых решений')
    parser.add_argument('--delay', type=float, default=0.5, help='пауза между запросами, с')
    parser.add_argument('-v', '--verbose', action='store_true', help='показывать и пропущенные каты')
    args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO,
                        format='%(asctime)s %(levelname)-7s %(message)s', datefmt='%H:%M:%S')
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    load_env(REPO_ROOT / '.env')
    user = args.user or os.environ.get('CODEWARS_USER') or 'BlazeStudio'
    root = args.root.resolve()
    cw = Codewars(args.delay)

    try:
        if args.html:
            found: dict[tuple[str, str], Solution] = {}
            for page in args.html:
                solutions, _ = parse_solutions_page(page.read_text(encoding='utf-8', errors='replace'))
                merge_solutions(found, solutions)
                log.info('%s: %d решений', page.name, len(solutions))
            solutions = list(found.values())
        else:
            authorize(cw)
            solutions = cw.fetch_solutions(user)
    except AuthError as e:
        log.error('%s', e)
        log.error('Если входите через GitHub — задайте пароль в настройках Codewars '
                  'или скопируйте cookie из браузера в CODEWARS_COOKIE (см. .env.example)')
        return 2

    katas = {s.kata_id for s in solutions}
    log.info('Найдено решений: %d (кат: %d, языки: %s)', len(solutions), len(katas),
             ', '.join(sorted({s.language for s in solutions})))

    index = RepoIndex(root)
    todo = []
    for sol in solutions:
        if index.contains(sol):
            log.debug('  уже есть: %s', sol.title)
        else:
            todo.append(sol)
    skipped = len(solutions) - len(todo)
    log.info('Уже в репозитории: %d, нужно загрузить: %d', skipped, len(todo))
    if args.limit is not None:
        todo = todo[:args.limit]

    kata_cache: dict[str, dict | None] = {}
    created, failed = 0, 0
    for n, sol in enumerate(todo, 1):
        log.info('[%d/%d] (осталось %d) %s', n, len(todo), len(todo) - n, sol.title)
        try:
            if sol.kata_id not in kata_cache:
                kata_cache[sol.kata_id] = cw.fetch_kata(sol.kata_id)
            kata = kata_cache[sol.kata_id]
            if kata is None:
                log.warning('  описание не найдено (ката удалена?), сохраняю только код')
                kata = {}
            if not sol.rank and (kata.get('rank') or {}).get('name'):
                sol.rank = kata['rank']['name']

            items = filter_markdown(kata.get('description') or '', sol.language)
            if sol.is_pandas:
                content = build_notebook(sol, items_to_markdown(items))
            else:
                content = build_source_file(sol, markdown_to_plain(items))

            path = target_path(root, sol)
            if path.exists():
                log.warning('  файл уже существует, пропускаю: %s', path.relative_to(root))
                continue
            if not args.dry_run:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding='utf-8', newline='\n')
            index.add(path, content)
            created += 1
            log.info('  %s %s', 'будет создан' if args.dry_run else 'создан', path.relative_to(root))
        except Exception as e:  # одна битая ката не должна останавливать выгрузку
            failed += 1
            log.error('  ошибка: %s', e)

    log.info('Готово: %s %d, пропущено (уже были) %d, ошибок %d',
             'будет создано' if args.dry_run else 'создано', created, skipped, failed)
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
