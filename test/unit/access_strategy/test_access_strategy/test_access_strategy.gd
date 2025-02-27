
extends GutTest

var AccessStrategy: GDScript = preload("res://addons/locker/scripts/access_strategy/access_strategy.gd")
var DoubledAccessStrategy: GDScript
var strategy: LokAccessStrategy

var files_path: String = "res://test/saves/"

func before_all() -> void:
	DoubledAccessStrategy = partial_double(AccessStrategy)

func before_each() -> void:
	strategy = DoubledAccessStrategy.new()

func after_all() -> void:
	LokFileSystemUtil.remove_directory_recursive_if_exists(files_path)
	LokFileSystemUtil.create_directory_if_not_exists(files_path)
	
	queue_free()

#region Method load_data

func test_load_data_loads_empty_partitions_as_default_partition() -> void:
	var file_path: String = files_path.path_join("file")
	
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	strategy.load_data(file_path, "sav", [ "" ], [], [])
	
	LokFileSystemUtil.remove_directory_if_exists(file_path)
	
	assert_called(strategy, "_load_partition", [ file_path.path_join("file.sav") ])

func test_load_data_returns_result_from_default_partition() -> void:
	var file_path: String = files_path.path_join("file")
	
	var partition_result: Dictionary = {
		"status": Error.OK,
		"data": {
			"accessor": {
				"loaded": true
			}
		}
	}
	var expected: Dictionary = partition_result.duplicate()
	expected["data"]["accessor"]["partition"] = "file"
	
	stub(strategy._load_partition).to_return(partition_result)
	
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	var result: Dictionary = strategy.load_data(file_path, "sav", [ "" ], [], [])
	
	LokFileSystemUtil.remove_directory_if_exists(file_path)
	
	assert_eq(result, expected, "Unexpected result")

func test_load_data_returns_result_from_default_partition_with_accessor_defined() -> void:
	var file_path: String = files_path.path_join("file")
	
	var partition_result: Dictionary = {
		"status": Error.OK,
		"data": {
			"accessor": {
				"loaded": true
			}
		}
	}
	var expected: Dictionary = partition_result.duplicate()
	expected["data"]["accessor"]["partition"] = "file"
	
	stub(strategy._load_partition).to_return(partition_result)
	
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	var result: Dictionary = strategy.load_data(
		file_path, "sav", [ "" ], [ "accessor" ], []
	)
	
	LokFileSystemUtil.remove_directory_if_exists(file_path)
	
	assert_eq(result, expected, "Unexpected result")

#endregion

#region Method remove_data

func test_remove_data_removes_empty_partitions_as_default_partition() -> void:
	var file_path: String = files_path.path_join("file")
	
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	strategy.remove_data(file_path, "sav", [ "" ], [], [])
	
	LokFileSystemUtil.remove_directory_if_exists(file_path)
	
	assert_called(
		strategy,
		"_remove_partition",
		[ file_path.path_join("file.sav"), [], [] ]
	)

func test_remove_data_returns_result_from_default_partition() -> void:
	var file_path: String = files_path.path_join("file")
	
	var partition_result: Dictionary = {
		"status": Error.OK,
		"data": {
			"accessor": {
				"loaded": true
			}
		},
		"updated_data": {}
	}
	var expected: Dictionary = partition_result.duplicate()
	expected["data"]["accessor"]["partition"] = "file"
	
	stub(strategy._remove_partition).to_return(partition_result)
	
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	var result: Dictionary = strategy.remove_data(
		file_path, "sav", [ "" ], [], []
	)
	
	LokFileSystemUtil.remove_directory_if_exists(file_path)
	
	assert_eq(result, expected, "Unexpected result")

func test_remove_data_returns_result_from_default_partition_with_accessor_passed() -> void:
	var file_path: String = files_path.path_join("file")
	
	var partition_result: Dictionary = {
		"status": Error.OK,
		"data": {
			"accessor": {
				"loaded": true
			}
		},
		"updated_data": {}
	}
	var expected: Dictionary = partition_result.duplicate()
	expected["data"]["accessor"]["partition"] = "file"
	
	stub(strategy._remove_partition).to_return(partition_result)
	
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	var result: Dictionary = strategy.remove_data(
		file_path, "sav", [ "" ], [ "accessor" ], []
	)
	
	LokFileSystemUtil.remove_directory_if_exists(file_path)
	
	assert_eq(result, expected, "Unexpected result")

#endregion

#region Method _get_partitions

func test_get_partitions_returns_all_saved_partitions() -> void:
	var file_path: String = files_path.path_join("file")
	
	LokFileSystemUtil.create_directory_if_not_exists(file_path)
	
	var expected: Array[String] = []
	
	for i: int in range(1, 4):
		var partition: String = "partition" + str(i) + ".sav"
		var partition_path: String = file_path.path_join(partition)
		
		LokFileSystemUtil.create_file_if_not_exists(partition_path)
		
		expected.append(partition)
	
	var result: Array[String] = strategy._get_partitions(file_path, "sav", [])
	
	LokFileSystemUtil.remove_directory_recursive_if_exists(file_path)
	
	assert_eq(result, expected, "Unexpected partitions")

func test_get_partitions_returns_only_wanted_partitions() -> void:
	var file_path: String = files_path.path_join("file")
	
	var expected: Array[String] = [ "partition2.sav" ]
	
	var result: Array[String] = strategy._get_partitions(file_path, "sav", [ "partition2" ])
	
	assert_eq(result, expected, "Unexpected partitions")

func test_get_partitions_returns_default_wanted_partition() -> void:
	var file_path: String = files_path.path_join("file")
	
	var expected: Array[String] = [ "file.sav" ]
	
	var result: Array[String] = strategy._get_partitions(file_path, "sav", [ "" ])
	
	assert_eq(result, expected, "Unexpected partitions")

#endregion

#region Method _get_file_id

func test_get_file_id_returns_file_id() -> void:
	var expected: String = "access_strategy"
	var result: String = strategy._get_file_id("file_access_strategy")
	
	assert_eq(result, expected, "Result unexpected")

func test_get_file_id_returns_file_prefix() -> void:
	var expected: String = "file"
	var result: String = strategy._get_file_id("file")
	
	assert_eq(result, expected, "Result unexpected")

func test_get_file_id_returns_file_prefix_if_it_has_underscore_at_end() -> void:
	var expected: String = "file"
	var result: String = strategy._get_file_id("file_")
	
	assert_eq(result, expected, "Result unexpected")

#endregion

#region Method get_saved_files_ids

func test_get_file_ids_returns_file_ids() -> void:
	var file1_name: String = "file_1"
	var file2_name: String = "file_2"
	var file3_name: String = "file_3"
	
	LokFileSystemUtil.create_directory_if_not_exists(
		files_path.path_join(file1_name)
	)
	LokFileSystemUtil.create_directory_if_not_exists(
		files_path.path_join(file2_name)
	)
	LokFileSystemUtil.create_directory_if_not_exists(
		files_path.path_join(file3_name)
	)
	
	var expected_data: Array[String] = [ "1", "2", "3" ]
	var result: Dictionary = strategy.get_saved_files_ids(files_path)
	
	var expected: Dictionary = {
		"status": Error.OK,
		"data": expected_data
	}
	
	assert_eq(result, expected, "Result unexpected")

func test_get_file_ids_returns_file_not_found() -> void:
	LokFileSystemUtil.remove_directory_recursive(files_path)
	
	var result: Dictionary = strategy.get_saved_files_ids(files_path)
	
	var expected: Dictionary = {
		"status": Error.ERR_FILE_NOT_FOUND,
		"data": []
	}
	
	assert_eq(result, expected, "Result unexpected")

#endregion
