//IN PROGRESS

/*Assignment agenda:

Design UVM testbench to perform verification of 4:1 Mux. Design code of 4:1 Mux is added in the Instruction tab.

*/

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
 
/////////////////////////Interface//////////////////////////
interface mux_if();
  logic [3:0] a,b,c,d;
  logic [1:0] sel;
  logic [3:0] y;
endinterface
 
/////////////////////////Transaction//////////////////////////
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  
  rand bit [3:0] a,b,c,d;
  rand bit [1:0] sel;
  bit [3:0] y;
  
  function new(input string path = "transaction");
    super.new(path);
  endfunction
  
  //Need????
  /* 
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(a, UVM_DEFAULT);
  `uvm_field_int(b, UVM_DEFAULT);
  `uvm_field_int(c, UVM_DEFAULT);
  `uvm_field_int(d, UVM_DEFAULT);
  `uvm_field_int(sel, UVM_DEFAULT);
  `uvm_field_int(y, UVM_DEFAULT);
  `uvm_object_utils_end
  */
  
endclass
 

 
/////////////////////////Sequence//////////////////////////

 
/////////////////////////Driver//////////////////////////
 

/////////////////////////Monitor//////////////////////////

/////////////////////////Scoreboard//////////////////////////

/////////////////////////Agent//////////////////////////
 

 
/////////////////////////Environment//////////////////////////

 
/////////////////////////Test//////////////////////////
 

/////////////////////////Module Top//////////////////////////
 
