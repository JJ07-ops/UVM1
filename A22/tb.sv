/*Assignment agenda:

Write a code to change the verbosity of the entire verification environment to UVM_DEBUG. To demonstrate successful configuration, print the value of the verbosity level on the console. 
Use GET and SET method with UVM_ROOT to configure Verbosity.

*/

//`timescale 1ns/1ps

`include "uvm_macros.svh" 
import uvm_pkg::*;

module tb;
  
  initial begin
    //change the verbosity lv with set
    uvm_root::get().set_report_verbosity_level(UVM_DEBUG);
    
    //print the verbosity level with get and info
    $display("Default Verbosity level : %0d", uvm_root::get().get_report_verbosity_level());
    
  end
  
endmodule
