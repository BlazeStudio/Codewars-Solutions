// Split by Mask
// https://www.codewars.com/kata/6a68ed7894f29599a1f7a248

// Given a xs and a mask (a list of lengths), split the string into its parts accordingly.
//
// Examples:
//
// |     xs        |  Mask (lengths) |          Output           |
// |---------------|-----------------|---------------------------|
// |  "1234567890" |  [3, 3, 4]      |  ["123", "456", "7890"]   |
// |  "codewars"   |  [4, 4]         |  ["code", "wars"]         |
//
// Notes:
//
// - The mask only contains strictly positive integers.
// - A mask is valid if and only if the sum of the lengths is equal to the length of the string.
//   Otherwise, return None.

fn split(xs: &str, mask: &[usize]) -> Option<Vec<String>> {
    if mask.iter().sum::<usize>() != xs.len() {
        return None;
    }
    
    let mut result = Vec::new();
    let mut start = 0;
    
    for &len in mask {
        result.push(xs[start..start + len].to_string());
        start += len;
    }
    
    Some(result)
}
