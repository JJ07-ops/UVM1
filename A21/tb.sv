/*Assignment agenda:

Create a class "my_object" by extending the UVM_OBJECT class. Add three logic datatype datamembers "a", "b", and "c" with sizes of 2, 4, and 8 respectively. 
Generate a random value for all the data members and send the values of the variables to the console by using the print method.

Use Automation for sending variable values to console.

*/

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
 
//myobject class
class my_object extends uvm_object;
  //call the factory
  `uvm_object_utils(my_object);
  
  //call the data members
  rand logic [1:0] a;
  rand logic [3:0] b;
  rand logic [7:0] c;
  
  //custom constructor
  function new(string path = "OBJ");
    super.new(path);
  endfunction
  
  //print function
  virtual function void do_print(uvm_printer printer);
    
    super.do_print(printer);
    
    printer.print_field_int("a",a,$bits(a),UVM_DEC);
    printer.print_field_int("b",b,$bits(b),UVM_DEC);
    printer.print_field_int("c",c,$bits(c),UVM_DEC);
    
  endfunction
endclass


module tb;
  my_object obj;
  
  initial begin
    obj = my_object::type_id::create("o");
    obj.randomize();
    obj.print();
  end
  
endmodule
