/*Assignment agenda:

Use UVM Analysis blocking port.

Design an environment consisting of a single producer class "PROD" and three subscribers viz., iz. "SUB1", "SUB2", and "SUB3". 
Add logic such that the producer broadcasts the name of the coder and all the subscribers are able to receive the string data sent by the producer. 
If Zen is writing the logic, then the producer should broadcast the string "ZEN" and all the subscribers must receive "ZEN".

*/

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

////////////////////////////////////////////////////////////////////////
 
class PROD extends uvm_component;
  `uvm_component_utils(PROD)
  
  string name = "SIM";
  
  uvm_analysis_port #(string) port;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port",this);
  endfunction
  
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("PROD",$sformatf("Name of coder: %0s",name),UVM_NONE);
    port.write(name);
    phase.drop_objection(this);
  endtask
  
endclass
 
///////////////////////////////////////////////////////////////
  
class SUB1 extends uvm_component;
  `uvm_component_utils(SUB1) 
  
  uvm_analysis_imp #(string, SUB1) imp;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp",this);
  endfunction
  
  virtual function void write(string name);
    `uvm_info("SUB1",$sformatf("Received name of coder: %0s",name),UVM_NONE)
  endfunction
    
endclass

 
//////////////////////////////////////////////////////////////////////////////
  
class SUB2 extends uvm_component;
  `uvm_component_utils(SUB2) 
  
  uvm_analysis_imp #(string, SUB2) imp;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp",this);
  endfunction
  
  virtual function void write(string name);
    `uvm_info("SUB2",$sformatf("Received name of coder: %0s",name),UVM_NONE)
  endfunction
    
endclass

 
//////////////////////////////////////////////////////////////////////////////
  
class SUB3 extends uvm_component;
  `uvm_component_utils(SUB3) 
  
  uvm_analysis_imp #(string, SUB3) imp;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp",this);
  endfunction
  
  virtual function void write(string name);
    `uvm_info("SUB3",$sformatf("Received name of coder: %0s",name),UVM_NONE)
  endfunction
    
endclass

 
//////////////////////////////////////////////////////////////////////////////


class env extends uvm_env;
  `uvm_component_utils(env); 
  
  PROD prod;
  SUB1 sub1;
  SUB2 sub2;
  SUB3 sub3;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    prod = PROD::type_id::create("prod",this);
    sub1 = SUB1::type_id::create("sub1",this);
    sub2 = SUB2::type_id::create("sub2",this);
    sub3 = SUB3::type_id::create("sub3",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    prod.port.connect(sub1.imp);
    prod.port.connect(sub2.imp);
    prod.port.connect(sub3.imp);
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
