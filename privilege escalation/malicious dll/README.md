# Description in Relation to Privilege Escalation
DLL used for DLL search order hijacking POC written in Rust. This does require local admin privilege. The reason for it is that the dll is going to execute under the same security context that the parent is executed under. So it needs to reside in the same folder of an application that is commonly run as a local admin.
# Creating Your Own
It's easy to create and setup a DLL to do what you want it to.
## Tools
* VS Code
* Sliver C2
* Dumpbin.exe
* Procmon.exe

With procmon, you're looking for processes that are trying to load dll's that don't exist within the current path. So the filter should look something like:
* Process is <Target Process>
* Path ends in .dll
* Result is name not found

When you have a dll picked out, you need to see what functions it exports and implement those. You can find the function using dumpbin.
* Dumpbin.exe /exports <Path to the dll>

The code just needs to export the function name for each function found using dumpbin. That is what pub extern "system" is for. The rust compiler also mangles the function name so the #[no_mangle] is also needed for this to work.
# How to Improve
Since the code of the exported function in the bad dll is no longer properly implemented, the victim program is going to crash. Obviously, this is bad opsec and a better way to do it is to forward the export calls.
As this is a simple POC meant for learning and I'm lazy, I'm not gonna do that.

VirtualAlloc is typically monitored so replacing that with the native api, NtAllocateVirtualMemory, would bypass more EDR's. 
