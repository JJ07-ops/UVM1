/*Assignment agenda:

Comparing two objects of the class.

1) Create a class "my_object" by extending the UVM_OBJECT class. Add three logic datatype datamembers "a", "b", and "c" with sizes of 2, 4, and 8 respectively.

2) Create two objects of my_object class in TB Top. Generate random data for data members of one of the object and then copy the data to other object by using clone method.

3) Compare both objects and send the status of comparison to Console using Standard UVM reporting macro. Add User defined implementation for the copy method.

*/

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
 
//myobject class
class my_object extends uvm_object;
  //call the factory
  //`uvm_object_utils(my_object);
  
  //call the data members
  rand logic [1:0] a;
  rand logic [3:0] b;
  rand logic [7:0] c;
  
  //custom constructor
  function new(string path = "OBJ");
    super.new(path);
  endfunction
  
  //do compare
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    my_object temp;
    int status;
    $cast(temp,rhs);
    status = super.do_compare(rhs,comparer) && (a == temp.a) && (b == temp.b) && (c == temp.c);
    return status;
  endfunction
  
  //user-defined copy implementation (not used???)
  virtual function void do_copy(uvm_object rhs);
    my_object temp;
    $cast(temp, rhs);
    super.do_copy(rhs);
    
    this.a = temp.a;
    this.b = temp.b;
    this.c = temp.c;
    
  endfunction
  
  
  //uvm utils
  `uvm_object_utils_begin(my_object)
  `uvm_field_int(a, UVM_DEC);
  `uvm_field_int(b, UVM_DEC);
  `uvm_field_int(c, UVM_DEC);
  `uvm_object_utils_end
  
endclass


module tb;
  my_object obj1;
  my_object obj2;
  int status;
  
  initial begin
    obj1 = my_object::type_id::create("obj1");
    obj1.randomize();
    //`uvm_info("TB_TOP", $sformatf("obj1 : a : %0d b : %0d c : %0d",obj1.a,obj1.b,obj1.c), UVM_NONE);
    obj1.print();
    
    $cast(obj2, obj1.clone());
    obj2.set_name("obj2");
    //`uvm_info("TB_TOP", $sformatf("obj2 : a : %0d b : %0d c : %0d",obj2.a,obj2.b,obj2.c), UVM_NONE);
    obj2.print();
    
    status = obj2.compare(obj1);
    `uvm_info("TB_TOP", $sformatf("status : %0d",status), UVM_NONE);
  end
  
endmodule
