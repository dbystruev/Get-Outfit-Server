import Foundation

// https://gist.github.com/pejalo/671dd2f67e3877b18c38c749742350ca

/// If an error occurs while getting the amount of memory used, the first returned value in the tuple will be 0.
func getMemoryUsedAndDeviceTotalInMegabytes() -> (Float, Float) {
        
    // https://stackoverflow.com/questions/5887248/ios-app-maximum-memory-budget/19692719#19692719
    // https://stackoverflow.com/questions/27556807/swift-pointer-problems-with-mach-task-basic-info/27559770#27559770
    
    var used_megabytes: Float = 0
    
    let total_bytes = Float(ProcessInfo.processInfo.physicalMemory)
    let total_megabytes = total_bytes / 1024.0 / 1024.0
    
    // var info = mach_task_basic_info()
    // var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    // let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
    //     $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
    //         task_info(
    //             mach_task_self_,
    //             task_flavor_t(MACH_TASK_BASIC_INFO),
    //             $0,
    //             &count
    //         )
    //     }
    // }
    
    // if kerr == KERN_SUCCESS {
    //     let used_bytes: Float = Float(info.resident_size)
    //     used_megabytes = used_bytes / 1024.0 / 1024.0
    // }
    
    return (used_megabytes, total_megabytes)
}