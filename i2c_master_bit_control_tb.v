`timescale 1ns/1ps
module i2c_master_bit_control_tb();

    reg  r_clk_master = 1'b0;
    reg  r_reset      = 1'b0;
    reg  r_data_in    = 1'b0;
    reg [2:0] r_cmd = 3'b000;

    
    wire w_data_out;
    wire w_testing;

    reg  r_io_SDA;
    wire w_SCL;
    wire w_io_SDA;
    wire w_io_SDA_receive;
    
    

    assign w_io_SDA = r_io_SDA;
    assign w_io_SDA_receive = w_io_SDA;
master_bit_control UUT
    (
        .i_clk_master(r_clk_master),
        .i_reset(r_reset),

        .i_data_in(r_data_in),

        .i_cmd(r_cmd),

        .o_data_out(w_data_out),
        .o_SCL(w_SCL),
        .io_SDA(w_io_SDA),
        .o_testing(w_testing)
    );
    always #10 r_clk_master <= !r_clk_master;
    initial 
        begin
            r_reset <= 1'b1;
            r_cmd <= 3'b000;
            r_data_in <= 1'b0;
            //r_io_SDA <= r_data_in;
            #1000
            r_reset <= 1'b0;
            r_cmd <= 3'b0;
            r_data_in <= 1'b0;
            //r_io_SDA <= r_data_in;
            #1000
            r_reset <= 1'b0;
            r_cmd <= 3'b001;
            r_data_in <= 1'b0;
            //r_io_SDA <= r_data_in;
            #12000

            //write procedure
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b1; //bit 1
            //r_io_SDA <= r_data_in;
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b0; //bit 2
            //r_io_SDA <= r_data_in;
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b1;// bit 3
            //r_io_SDA <= r_data_in;
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b0; //bit 4
            //r_io_SDA <= r_data_in;
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b1;// bit 5
            //r_io_SDA <= r_data_in;
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b0; // bit 6
            //r_io_SDA <= r_data_in;
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b1; // bit 7
            //r_io_SDA <= r_data_in;
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b010;
            r_data_in <= 1'b1; // bit 8 read or write
            //r_io_SDA <= r_data_in;
            #10000

            // read the ACK from the slave
            //r_reset <= 1'b0;
            //r_cmd <= 3'b011;
            //r_io_SDA <= 1'b0;
            //#10000
            
            // stop procedure
            r_reset <= 1'b0;
            r_cmd <= 3'b100;
            r_data_in <= 1'b0; //stop bit
            #10000
            r_reset <= 1'b0;
            r_cmd <= 3'b000;
            r_data_in <= 1'b0; // back to idle
            #10000;
            
        end
endmodule