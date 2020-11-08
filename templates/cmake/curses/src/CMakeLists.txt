include_directories(.)
# add_library(obj1 OBJECT obj1.cc obj1.h)
# target_compile_features(obj1 PUBLIC cxx_auto_type $<IF:$<COMPILE_FEATURES:cxx_return_type_deduction>,cxx_return_type_deduction,cxx_trailing_return_types> cxx_noexcept cxx_nullptr cxx_decltype)

# add_executable(game main.cc main.h obj1 correct_curses.h)
# target_include_directories(game PRIVATE "${CURSES_INCLUDE_DIRS}")
# target_compile_features(game PRIVATE cxx_lambdas cxx_decltype)
# target_link_libraries(game "${CURSES_LIBRARIES}")

# Tests
# add_executable(test_1 EXCLUDE_FROM_ALL test_1.cc obj1 correct_curses.h)
