class_name RNGAdditions extends Object


static func weighted_get_item(rng: RandomNumberGenerator, weights: Array) -> int:
	var sum = 0
	for w in weights:
		sum += w
	
	var value = (randf() if rng == null else rng.randf()) * sum
	var stepSum = 0
	for i in range(len(weights)):
		if value < weights[i] + stepSum:
			return i
		stepSum += weights[i]
	return -1


static func weighted_shuffle(rng: RandomNumberGenerator, items: Array, weights: Array) -> Array:
	var grabbag = weights.duplicate()
	var result = []
	
	for i in range(len(items)):
		var idx = weighted_get_item(rng, grabbag)
		grabbag.remove_at(idx)
		result.append(items[idx])

	return result
