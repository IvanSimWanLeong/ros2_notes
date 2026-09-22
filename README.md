# Network tuning
https://autowarefoundation.github.io/autoware-documentation/main/installation/additional-settings-for-developers/network-configuration/dds-settings/      
```
sudo nano /etc/sysctl.d/10-cyclone-max.conf
```
copy the following into the file:    
net.core.rmem_max=2147483647  # 2 GiB, default is 208 KiB    
net.ipv4.ipfrag_time=3  # in seconds, default is 30 s    
net.ipv4.ipfrag_high_thresh=134217728  # 128 MiB, default is 256 KiB

# cmake
### dependencies
```
set(dependencies
  rclcpp
  geometry_msgs
  tf2
  tf2_ros
)

foreach(pkg IN LISTS dependencies)
  find_package(${pkg} REQUIRED)
endforeach()
```

### include directories
```
include_directories(
  include
)
```

### eigen lib
```
find_package(Eigen3 REQUIRED)
include_directories(SYSTEM ${EIGEN3_INCLUDE_DIRS})
```

### libraries
```
add_library(lib_name SHARED
  src/utils/---.cpp
  src/---.cpp
)

target_include_directories(lib_name PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
)

target_link_libraries(lib_name
  jsoncpp
  yaml-cpp
)

ament_target_dependencies(lib_name
  ${dependencies}
)
```

### executable
```
add_executable(node_name
  src/---.cpp
)

target_include_directories(node_name PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
)

target_link_libraries(node_name
  lib_name
)

### for jazzy and older distro
ament_target_dependencies(node_name PUBLIC
  ${dependencies}
)

### for lyrical (no more ament_target_dependencies)
target_link_libraries(node_name PUBLIC
  lib_name
  rclcpp::rclcpp
  std_msgs::std_msgs
)
```

### install
```
install(DIRECTORY include/${PROJECT_NAME}/
  DESTINATION include/${PROJECT_NAME}
)

install(
  TARGETS lib1 lib2
  EXPORT ${PROJECT_NAME} # only one export
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include
)

install(TARGETS 
  node_name1 
  node_name2
  DESTINATION lib/${PROJECT_NAME})

install(DIRECTORY launch config
  DESTINATION share/${PROJECT_NAME}/)
```

### ament export
```
ament_export_dependencies(${dependencies})
ament_export_include_directories(include) # name of folder in install/${PROJECT_NAME}/
ament_export_libraries(lib1 lib2) # all libraries
ament_export_targets(${PROJECT_NAME})

ament_package()
```
