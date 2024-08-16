/*Assignment agenda:

Demonstrate Start of Elaboration phase executes in Bottom-Up fashion.

Add End of elaboration phase in Driver, Monitor, Environment and Test Class. 
Driver and Monitor are child to Environment while Environment is child to Test Class. 
Build Heirarchy and perform execution of the code to verify End of ELaboration phase executes in Bottom-Up fashion. Use template mentioned below.


Student's note: Assignment name was A51 but the student changed it to A61 due to the assignment being in Section 6 of the course.
*/

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
 
 
///////////////////////////////////////////////////////////////
 
class driver extends uvm_driver;
  `uvm_component_utils(driver) 
  
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("driver","Driver End of Elaboration Phase executed",UVM_NONE);
  endfunction
 
  
endclass
 
///////////////////////////////////////////////////////////////
 
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor) 
  
  
  function new(string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("monitor","Monitor End of Elaboration Phase executed",UVM_NONE);
  endfunction
 
  
endclass
 
//////////////////////////////////////////////////////////////////////////////

class env extends uvm_env;
  `uvm_component_utils(env) 
  
  driver d;
  monitor m;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d = driver::type_id::create("d",this);
    m = monitor::type_id::create("m",this);
    //`uvm_info("env","Environment Build Face executed");
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("env","Environment End of Elaboration Phase executed",UVM_NONE);
  endfunction
 
endclass
 
//////////////////////////////////////////////////////////////////////////////
 
class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
    //`uvm_info("test","Test Build Face executed");
   endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("test","Test End of Elaboration Phase executed",UVM_NONE);
  endfunction
  
endclass
 
///////////////////////////////////////////////////////////////////////////
module tb;
  
  initial begin
    run_test("test");
  end
  
 
endmodule
