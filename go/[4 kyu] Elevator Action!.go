// Elevator Action!
// https://www.codewars.com/kata/654cdf611d68c91228af27f1

// You're an elevator.

// People on each floor get on you in the order they are queued as long as you're stopped on their floor.

// Your doors are one-person wide. No one can board you when someone else is departing or vice versa.

// You must stop at each floor you pass that you can drop off and/or pick up passengers. Conversely, you don't stop if you're not changing passengers.

// You can't switch directions while holding passengers.

// People won't get on you if you're not going in the direction they want to go.

// During a stop, all passengers who can get off gets off BEFORE any new passengers could get on.

// When you're empty (at any point), you must go TOWARD the next person in the queue, taking anyone going in that direction along your path if you're capable.

// When you're empty AND you're on the same floor as the next person in the queue, you must now go in the direction they want to go.

// You must stop to open your doors, even if you haven't moved a floor. You begin each day with closed doors.

// Up to 5 people can be on you at a time.

// Given a starting_floor and a queue of people represented by from the floor they're on to the floor they want to go, return the order of stops you will take this day.

// Example
// Given this queue:

// queue := []Person{
//   {From: 3, To: 2}, // Al
//   {From: 5, To: 2}, // Betty
//   {From: 2, To: 1}, // Charles
//   {From: 2, To: 5}, // Dan
//   {From: 4, To: 3}, // Ed
// }
// then

// startingFloor := 1
// Order(startingFloor, queue)
// should return:

// []int{2, 5, 4, 3, 2, 1}
// Explanation
// You start on floor 1. Al is the first to queue for the elevator so you make your way toward him traveling UP.

// Going up a floor, you notice Charles and Dan on floor 2, however only Dan wants to go up so your first stop is 2 to pick up Dan.

// Going up to floor 3, you have now reached Al, but unfortunately for him, he wants to go down, and you can't switch directions until you drop off Dan. You promise to get Al later, so you pass him for now.

// With no one else going up on your path, your second stop is 5 to drop off Dan. Now that you're empty, you move toward Al again who is now below you. Since you begin traveling DOWN, Betty, who's also on floor 5, joins you.

// You stop on 4 to pick up Ed who is also going down.

// You stop on 3 to drop off Ed. Meanwhile, you finally pick up Al.

// You stop on 2 to drop off Al and Betty. You finally pick up Charles.

// You stop on 1 to drop off Charles, the last person to transport.

// Final Note
// The building you operate in may have ANY arbitrarily large number of stories (or basements) that people will want to travel between. For a given day, you should not expect more than 500 people to ride you.

package kata

func Order(level int, queue []Person) []int {
	if len(queue) == 0 {
		return []int{}
	}

	waiting := make([]Person, len(queue))
	copy(waiting, queue)
	picked := make([]bool, len(queue))

	onboard := make([]int, 0, 5)
	stops := []int{}
	cur := level
	dir := 0

	nextPerson := func() int {
		for i := range picked {
			if !picked[i] {
				return i
			}
		}
		return -1
	}

	canPickAt := func(floor int, d int) bool {
		for i, p := range waiting {
			if picked[i] || p.From != floor {
				continue
			}
			pd := 0
			if p.To > p.From {
				pd = 1
			} else if p.To < p.From {
				pd = -1
			}
			if pd == d {
				return true
			}
		}
		return false
	}

	abs := func(x int) int {
		if x < 0 {
			return -x
		}
		return x
	}

	const capacity = 5
	maxSteps := 10000
	for step := 0; step < maxSteps; step++ {
		np := nextPerson()
		if np == -1 && len(onboard) == 0 {
			break
		}

		if len(onboard) == 0 {
			if np == -1 {
				break
			}
			targetFrom := waiting[np].From
			if cur == targetFrom {
				if waiting[np].To > cur {
					dir = 1
				} else {
					dir = -1
				}
			} else if targetFrom > cur {
				dir = 1
			} else {
				dir = -1
			}
		}

		needStopHere := false
		for _, to := range onboard {
			if to == cur {
				needStopHere = true
				break
			}
		}
		if !needStopHere && len(onboard) < capacity && canPickAt(cur, dir) {
			needStopHere = true
		}
		if !needStopHere && len(onboard) == 0 && np != -1 && waiting[np].From == cur {
			needStopHere = true
		}

		if needStopHere {
			if len(stops) == 0 || stops[len(stops)-1] != cur {
				stops = append(stops, cur)
			}

			newOnboard := onboard[:0]
			for _, to := range onboard {
				if to != cur {
					newOnboard = append(newOnboard, to)
				}
			}
			onboard = newOnboard

			if len(onboard) == 0 {
				np = nextPerson()
				if np != -1 {
					targetFrom := waiting[np].From
					if cur == targetFrom {
						if waiting[np].To > cur {
							dir = 1
						} else {
							dir = -1
						}
					} else if targetFrom > cur {
						dir = 1
					} else {
						dir = -1
					}
				}
			}

			for i := 0; i < len(waiting) && len(onboard) < capacity; i++ {
				if picked[i] || waiting[i].From != cur {
					continue
				}
				p := waiting[i]
				pd := 0
				if p.To > p.From {
					pd = 1
				} else if p.To < p.From {
					pd = -1
				}
				if pd == dir {
					onboard = append(onboard, p.To)
					picked[i] = true
				}
			}
			continue
		}

		candidates := make(map[int]bool)

		for _, to := range onboard {
			if (dir == 1 && to > cur) || (dir == -1 && to < cur) {
				candidates[to] = true
			}
		}

		if len(onboard) < capacity {
			for i, p := range waiting {
				if picked[i] {
					continue
				}
				from := p.From
				if (dir == 1 && from > cur) || (dir == -1 && from < cur) {
					pd := 0
					if p.To > from {
						pd = 1
					} else if p.To < from {
						pd = -1
					}
					if pd == dir {
						candidates[from] = true
					}
				}
			}
		}

		if len(onboard) == 0 {
			np = nextPerson()
			if np != -1 {
				candidates[waiting[np].From] = true
			}
		}

		if len(candidates) == 0 {
			break
		}

		nextStop := 0
		minDist := -1
		found := false
		for f := range candidates {
			var d int
			ok := false
			if dir == 1 && f > cur {
				d = f - cur
				ok = true
			} else if dir == -1 && f < cur {
				d = cur - f
				ok = true
			} else if len(onboard) == 0 {
				d = abs(f - cur)
				ok = true
			}
			if ok && (!found || d < minDist) {
				minDist = d
				nextStop = f
				found = true
			}
		}

		if !found {
			break
		}

		if len(stops) == 0 || stops[len(stops)-1] != nextStop {
			stops = append(stops, nextStop)
		}
		cur = nextStop

		newOnboard := onboard[:0]
		for _, to := range onboard {
			if to != cur {
				newOnboard = append(newOnboard, to)
			}
		}
		onboard = newOnboard

		if len(onboard) == 0 {
			np = nextPerson()
			if np != -1 {
				targetFrom := waiting[np].From
				if cur == targetFrom {
					if waiting[np].To > cur {
						dir = 1
					} else {
						dir = -1
					}
				} else if targetFrom > cur {
					dir = 1
				} else {
					dir = -1
				}
			}
		}

		for i := 0; i < len(waiting) && len(onboard) < capacity; i++ {
			if picked[i] || waiting[i].From != cur {
				continue
			}
			p := waiting[i]
			pd := 0
			if p.To > p.From {
				pd = 1
			} else if p.To < p.From {
				pd = -1
			}
			if pd == dir {
				onboard = append(onboard, p.To)
				picked[i] = true
			}
		}
	}

	return stops
}