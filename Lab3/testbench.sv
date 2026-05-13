`timescale 1ns/10ps
module testbench();
    logic clk, reset;
    
    // instantiate cpu
    cpu dut(.clk(clk), .reset(reset));
    
    // generate clock - very long per spec
    initial clk = 0;
    always #5000 clk = ~clk;
    
    // reset then run
    initial begin
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        
        // run enough cycles for benchmark to finish
        repeat(1000) @(posedge clk);
        $stop;
    end
endmodule