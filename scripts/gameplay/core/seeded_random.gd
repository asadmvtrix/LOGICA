class_name SeededRandom
extends RefCounted
## Deterministic random numbers from a text key, so the same key always
## produces the same puzzle on every device.


static func create(key: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(key)
	return rng


static func shuffle(items: Array, rng: RandomNumberGenerator) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = items[i]
		items[i] = items[j]
		items[j] = tmp


static func range_shuffled(count: int, rng: RandomNumberGenerator) -> Array:
	var items := range(count)
	shuffle(items, rng)
	return items
