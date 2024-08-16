/*Assignment agenda:

Send transaction data from COMPA to COMPB with the help of TLM PUT PORT to PUT IMP . 
Transaction class code is added in Instruction tab. Use UVM core print method to print the values of data members of transaction class.
Send transaction data from COMPA to COMPB with the help of TLM PUT PORT to PUT IMP .

*/

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
 

/////////////////////////////////////////////////////////////
class transaction extends uvm_sequence_item;
 
  bit [3:0] a = 12;
  bit [4:0] b = 24;
  int c = 256;
  
  function new(string inst = "transaction");
    super.new(inst);
  endfunction
  
  
    `uvm_object_utils_begin(transaction)
  `uvm_field_int(a, UVM_DEFAULT | UVM_DEC);
  `uvm_field_int(b, UVM_DEFAULT | UVM_DEC);
  `uvm_field_int(c, UVM_DEFAULT | UVM_DEC); 
    `uvm_object_utils_end
  
  
  
endclass
///////////////////////////////////////////////////////////////
 
class COMPA extends uvm_component;
 `uvm_component_utils(COMPA)
  
  transaction data;
  
  uvm_blocking_put_port #(transaction) port;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    data = transaction::type_id::create("transaction");
    data.a = 13;
    port = new("port",this);
  endfunction
  
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    data.print();
    port.put(data);
    phase.drop_objection(this);
  endtask
  
endclass
 
///////////////////////////////////////////////////////////////
  
class COMPB extends uvm_component;
  `uvm_component_utils(COMPB) 
  
  uvm_blocking_put_imp #(transaction,COMPB) imp;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp",this);
  endfunction
  
  virtual function void put(transaction data);
    data.print();
  endfunction
    
endclass

 
//////////////////////////////////////////////////////////////////////////////

class env extends uvm_env;
  `uvm_component_utils(env)
  
  COMPA cmpA;
  COMPB cmpB;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cmpA = COMPA::type_id::create("cmpA",this);
    cmpB = COMPB::type_id::create("cmpB",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    cmpA.port.connect(cmpB.imp);
  endfunction
 
endclass
 
//////////////////////////////////////////////////////////////////////////////
 
class test extends uvm_test;
 `uvm_component_utils(test)
  
  env e;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
   endfunction
  
endclass
 
///////////////////////////////////////////////////////////////////////////
module tb;
  
  initial begin
    run_test("test");
  end
  
 
endmodule
