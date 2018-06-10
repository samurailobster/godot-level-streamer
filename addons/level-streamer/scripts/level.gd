
var filename
var bounds
var transform
var count = 0

var _cache_resource
var _levels_root
var _resource_registry
var _instance
var _mu = Mutex.new()

func _init(filename, transform, bounds, levels_root, _cache_resources, _resource_registry):
	self.filename = filename
	self.transform = transform
	self.bounds = bounds
	self._levels_root = levels_root
	self._cache_resource = _cache_resources
	self._resource_registry = _resource_registry

func add_ref(d):
	_mu.lock()
	count += d
	_mu.unlock()

func ref():
	add_ref(1)
	
func deref():
	add_ref(-1)

func load_level():
	_mu.lock()
	if count == 0:
		print(count)
		var resource = load(filename)
		_instance = resource.instance()
		_instance.transform = transform
		_levels_root.add_child(_instance)
	ref()
	_mu.unlock()

func unload_level():
	_mu.lock()
	print(count)
	if count == 1:
		_levels_root.call_deferred("remove_child", _instance)
		_instance.queue_free()
		_instance = null
		if not _cache_resource:
			_resource_registry.unload_resource(filename)
	deref()
	_mu.unlock()

func _is_loaded():
	_mu.lock()
	var ins = _instance
	_mu.unlock()
	return ins != null
