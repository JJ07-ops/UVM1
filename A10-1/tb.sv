/*Assignment agenda:

Design UVM TB to perform verification of Data flipflop (D-FF). Design code is mentioned in the instruction tab.

*/

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
 
/////////////////////////Interface//////////////////////////
interface dff_if();
  logic clk;
  logic rst;
  logic din;
  logic dout;
endinterface
 
/////////////////////////Transaction//////////////////////////
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  
  //call the variables
  rand bit din;
  bit dout;
  
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
      `uvm_info("GEN",$sformatf("din : %0d",t.din),UVM_NONE);
      finish_item(t);
    end
  endtask
endclass
 
/////////////////////////Driver//////////////////////////
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  //declare variables
  transaction tc;
  virtual dff_if dif;
  
  //new function
  function new(input string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual dff_if)::get(this,"","dif",dif))
       `uvm_error("DRV","Unable to access uvm_config_db");
  endfunction
  
  //reset task
  task reset();
    dif.rst <= 1'b1;
    dif.din <= 1'b0;
    dif.dout <= 1'b0;
    repeat(5) @(posedge dif.clk);
    dif.rst <= 1'b0;
    `uvm_info("DRV", "Reset Finished", UVM_NONE);
  endtask
       
  //run phase to receive from sequence and drive the DUT
  virtual task run_phase(uvm_phase phase);
    reset();
    forever begin
      seq_item_port.get_next_item(tc);
      dif.din <= tc.din;
      `uvm_info("DRV",$sformatf("din : %0d",tc.din),UVM_NONE);
      seq_item_port.item_done();
      repeat(2) @(posedge dif.clk);
    end
  endtask

endclass

/////////////////////////Monitor//////////////////////////
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  //declare variables
  uvm_analysis_port #(transaction) send;
  transaction t;
  virtual dff_if dif;
  
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
    
    if(!uvm_config_db #(virtual dff_if)::get(this,"","dif",dif)) 
   	`uvm_error("MON","Unable to access uvm_config_db");
  endfunction
  
  //run phase
  virtual task run_phase(uvm_phase phase);
    @(negedge dif.rst);
    forever begin
      repeat(2) @(posedge dif.clk);
      t.din = dif.din;
      t.dout = dif.dout;
      `uvm_info("MON",$sformatf("din : %0d dout : %0d",t.din,t.dout),UVM_NONE);
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
    `uvm_info("SCO",$sformatf("din : %0d dout : %0d",tr.din,tr.dout),UVM_NONE);
    
    //compare
    if(tr.din == tr.dout)
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
    repeat(2) @(posedge e.a.d.dif.clk);
    
    phase.drop_objection(this);
  endtask
endclass
 

/////////////////////////Module Top//////////////////////////
 
module dff_tb;
  
  //declare the interface
  dff_if dif();
  
  //connect the interface with the duty
  dff dut(.din(dif.din),.dout(dif.dout),.clk(dif.clk),.rst(dif.rst));
  
  //initialize the clock and rst
  initial begin
    dif.clk = 0;
    dif.rst = 0;
  end
  
  //run the clock
  always #10 dif.clk = ~dif.clk;
  
  //config the interface and run the code
  initial begin
    uvm_config_db #(virtual dff_if)::set(null, "uvm_test_top.e.a*", "dif", dif);
    run_test("test"); 
  end
  
  //dump file
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
