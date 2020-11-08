add_test(
	NAME
		Test1
	COMMAND
		"${CMAKE_CTEST_COMMAND}"
			--build-and-test "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}"
			--build-generator "${CMAKE_GENERATOR}"
			--build-nocmake
			--build-target test1
			--test-command "$<TARGET_FILE:test1>"
)
