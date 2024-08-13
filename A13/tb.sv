/*Assignment agenda:

Override the UVM_WARNING action to make quit_count equal to the number of times UVM_WARNING executes. Write an SV code to send four random messages to a terminal with potential error severity, Simulation must stop as soon as we reach to quit_count of four. Do not use UVM_INFO, UVM_ERROR, UVM_FATAL,

*/

//`timescale 1ns/1ps

`include "uvm_macros.svh" 
import uvm_pkg::*;

class driver extends uvm_driver;
  `uvm_component_utils(driver);
  
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction
  
  task run();
    `uvm_warning("TB_TOP", "Hello World");
  endtask
endclass

module tb;
  
  driver d;
  
  initial begin
    //construct d
    d = new("DRV",null);
    
    //override uvm warning action
    d.set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_COUNT);
    d.set_report_max_quit_count(4);
    
    //keep printing with uvm warning
    forever begin
      d.run();
    end
    
  end
  

  
endmodule
