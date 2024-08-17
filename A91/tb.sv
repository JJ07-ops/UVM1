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
  
  //call the variables
  rand bit [3:0] a,b,c,d;
  rand bit [1:0] sel;
  bit [3:0] y;
  
  //new function
  function new(input string path = "transaction");
    super.new(path);
  endfunction
  
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
class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)
  
  //declare the variables
  transaction t;
  integer counter = 10;
  
  //new function
  function new(input string path = "generator");
    super.new(path);
  endfunction
  
  //main body task to randomize and send to driver
  virtual task body();
    t = transaction::type_id::create("t");
    repeat(counter) begin
      start_item(t);
      t.randomize();
      `uvm_info("GEN",$sformatf("a : %0d b : %0d c : %0d d : %0d sel : %0d",t.a,t.b,t.c,t.d,t.sel),UVM_NONE);
      finish_item(t);
    end
  endtask
endclass
 
/////////////////////////Driver//////////////////////////
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  //declare variables
  transaction tc;
  virtual mux_if mif;
  
  //new function
  function new(input string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual mux_if)::get(this,"","mif",mif))
       `uvm_error("DRV","Unable to access uvm_config_db");
  endfunction
       
  //run phase to receive from sequence and drive the DUT
  virtual task run_phase(uvm_phase phase);
    forever begin
      
      seq_item_port.get_next_item(tc);
      mif.a <= tc.a;
      mif.b <= tc.b;
      mif.c <= tc.c;
      mif.d <= tc.d;
      mif.sel <= tc.sel;
      `uvm_info("DRV",$sformatf("a : %0d b : %0d c : %0d d : %0d sel : %0d",tc.a,tc.b,tc.c,tc.d,tc.sel),UVM_NONE);
      seq_item_port.item_done();
      #10;
    end
  endtask

endclass

/////////////////////////Monitor//////////////////////////
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  //declare variables
  uvm_analysis_port #(transaction) send;
  transaction t;
  virtual mux_if mif;
  
  //function new
  function new(input string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
    //send = new("send", this);
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
   
    super.build_phase(phase);
    
    send = new("send", this);
    
    t = transaction::type_id::create("t");
    
    if(!uvm_config_db #(virtual mux_if)::get(this,"","mif",mif)) 
   	`uvm_error("MON","Unable to access uvm_config_db");
  endfunction
  
  //run phase
  virtual task run_phase(uvm_phase phase);
    forever begin
      #10;
      t.a = mif.a;
      t.b = mif.b;
      t.c = mif.c;
      t.d = mif.d;
      t.sel = mif.sel;
      t.y = mif.y;
      `uvm_info("MON",$sformatf("a : %0d b : %0d c : %0d d : %0d sel : %0d y : %0d",t.a,t.b,t.c,t.d,t.sel,t.y),UVM_NONE);
      send.write(t);
    end
  endtask
endclass

/////////////////////////Scoreboard//////////////////////////
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  //declare variables
  uvm_analysis_imp #(transaction,scoreboard) recv;
  transaction tr;
  
  //function new
  function new(input string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    tr = transaction::type_id::create("tr");
  endfunction
  
  //write and compare phase
  virtual function void write(input transaction t);
    tr = t;
    `uvm_info("SCO",$sformatf("a : %0d b : %0d c : %0d d : %0d sel : %0d y : %0d",tr.a,tr.b,tr.c,tr.d,tr.sel,tr.y),UVM_NONE);
    
    //case statements
    if(tr.sel == 2'b00 && tr.y == tr.a)
      `uvm_info("SCO","Test passed",UVM_NONE)
    else if(tr.sel == 2'b01 && tr.y == tr.b)
      `uvm_info("SCO","Test passed",UVM_NONE)
    else if(tr.sel == 2'b10 && tr.y == tr.c)
      `uvm_info("SCO","Test passed",UVM_NONE)
    else if(tr.sel == 2'b11 && tr.y == tr.d)
      `uvm_info("SCO","Test passed",UVM_NONE)
    else
      `uvm_info("SCO","Test failed",UVM_NONE);
    
  
  endfunction
endclass

/////////////////////////Agent//////////////////////////

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  //declare variables
  monitor m;
  driver d;
  uvm_sequencer #(transaction) seqr;
  
  //function new
  function new(input string inst = "agent", uvm_component c);
    super.new(inst, c);
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("m",this);
    d = driver::type_id::create("d",this);
    seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
  endfunction
  
  //connect phase (driver and sequencer)
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction 
endclass

 
/////////////////////////Environment//////////////////////////
class env extends uvm_env;
  `uvm_component_utils(env)
  
  //declare variables
  agent a;
  scoreboard s;
  
  //function new
  function new(input string inst = "agent", uvm_component c);
    super.new(inst, c);
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a",this);
    s = scoreboard::type_id::create("s",this);
  endfunction
  
  //connect phase (monitor and scoreboard)
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction 
endclass

 
/////////////////////////Test//////////////////////////
class test extends uvm_test;
  `uvm_component_utils(test)
  
  //declare variables
  env e;
  generator gen;
  
  //function new
  function new(input string inst = "agent", uvm_component c);
    super.new(inst, c);
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
    gen = generator::type_id::create("gen");
  endfunction
  
  //run the sequence
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    gen.start(e.a.seqr);
    #10
    
    phase.drop_objection(this);
  endtask
endclass
 

/////////////////////////Module Top//////////////////////////
 
module mux_tb;
  
  //declare the interface
  mux_if mif();
  
  //connect the interface with the duty
  mux dut(.a(mif.a),.b(mif.b),.c(mif.c),.d(mif.d),.sel(mif.sel),.y(mif.y));
  
  //config the interface and run the code
  initial begin
    uvm_config_db #(virtual mux_if)::set(null, "uvm_test_top.e.a*", "mif", mif);
    run_test("test"); 
  end
  
  //dump file
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
