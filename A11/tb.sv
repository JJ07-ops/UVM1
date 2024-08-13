/*Assignment agenda:

Send the name of the first RTL that you designed in Verilog with the help of reporting Macro. Do not override the default verbosity. Expected Output : "First RTL : Your_System_Name"

*/

//`timescale 1ns/1ps

`include "uvm_macros.svh" 
import uvm_pkg::*;

module tb;
  
  initial begin
    `uvm_info("TB_TOP","First RTL : Your_System_Name",UVM_NONE);
    
  end
  
endmodule
