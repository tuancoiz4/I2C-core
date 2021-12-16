module master_bit_control
    (
        input       i_clk_master,
        input       i_reset,
        input       i_data_in,

        input [2:0] i_cmd,
        
        output      o_data_out,
        output      o_SCL,
        inout       io_SDA,
        output      o_testing
    );

    reg [7:0] r_clk_counter = 8'b0;
    reg       r_clk = 1'b0; // divided 2us clock
    reg [15:0] r_ST_main;
    reg       r_SCL = 1'b1;
    reg       r_SDA = 1'b1;
    reg       r_data_out = 1'b0;
    
    wire w_clk;
    localparam [15:0] IDLE    = 16'b0;
    localparam [15:0] START_A = 16'b0000000000000001;
    localparam [15:0] START_B = 16'b0000000000000010;
    localparam [15:0] START_C = 16'b0000000000000011;
    localparam [15:0] START_D = 16'b0000000000000100;
    localparam [15:0] START_E = 16'b0000000000000101;
    localparam [15:0] WRITE_A = 16'b0000000000000110;
    localparam [15:0] WRITE_B = 16'b0000000000000111;
    localparam [15:0] WRITE_C = 16'b0000000000001000;
    localparam [15:0] WRITE_D = 16'b0000000000001001;
    localparam [15:0] READ_A =  16'b0000000000001010;
    localparam [15:0] READ_B =  16'b0000000000001011;
    localparam [15:0] READ_C =  16'b0000000000001100;
    localparam [15:0] READ_D =  16'b0000000000001101;
    localparam [15:0] STOP_A =  16'b0000000000001110;
    localparam [15:0] STOP_B =  16'b0000000000001111;
    localparam [15:0] STOP_C =  16'b0000000000010000;
    localparam [15:0] STOP_D =  16'b0000000000010001;
    // create 2us clock
    // input clock = 50 MHz ~ 0.02 us, we need 2us clock so each cycle high and low of clock is 1us and counter need to 50 => 0-49
    always @(posedge i_reset or posedge i_clk_master)
        begin
            if (i_reset)
                begin
                    r_clk_counter <= 8'b0;
                    r_ST_main <= IDLE;
                end
            else
                begin
                    r_clk_counter <= r_clk_counter + 1;
                    if ( r_clk_counter == 8'b00110001 ) // counter to 49
                        begin
                            r_clk <= !r_clk;
                            r_clk_counter <= 8'b0;
                        end 
                end
        end
    assign o_testing = r_clk;
    assign w_clk = r_clk;

    // state machine of bit controller
    always @(posedge w_clk or posedge i_reset ) 
        begin
            if (i_reset)
                begin
                    r_ST_main <= IDLE;
                end
            else
                begin
                    case (r_ST_main)
                    IDLE:
                        begin
                            case(i_cmd)
                                3'b001: // start action
                                    r_ST_main <= START_A;
                                3'b010: // write action
                                    r_ST_main <= WRITE_A;
                                3'b011: // read action
                                    r_ST_main <= READ_A;
                                3'b100:
                                    r_ST_main <= STOP_A;
                                default:
                                    r_ST_main <= IDLE;
                            endcase
                        r_SCL <= r_SCL;
                        r_SDA <= r_SDA;
                        end
                    START_A:
                        begin
                            r_SCL     <=     1'b1;
                            r_SDA     <=     1'b1;
                            r_ST_main <=     START_B;
                        end
                    START_B:
                        begin
                            r_SCL     <=     1'b1;
                            r_SDA     <=     1'b1;
                            r_ST_main <=     START_C;
                        end
                    START_C:
                        begin
                            r_SCL     <=     1'b1;
                            r_SDA     <=     1'b0;
                            r_ST_main <=     START_D;
                        end
                    START_D:
                        begin
                            r_SCL     <=     1'b0;
                            r_SDA     <=     1'b0;
                            r_ST_main <=     START_E;
                        end
                    START_E:
                        begin
                            r_SCL     <=     1'b0;
                            r_SDA     <=     1'b0;
                            r_ST_main <=     IDLE;
                        end
                    WRITE_A:
                        begin
                            r_SCL     <=    1'b0;
                            r_SDA     <=    i_data_in;
                            r_ST_main <=    WRITE_B;
                        end
                    WRITE_B:
                        begin
                            r_SCL     <=    1'b1;
                            r_SDA     <=    i_data_in;
                            r_ST_main <=    WRITE_C;
                        end
                    WRITE_C:
                        begin
                            r_SCL     <= 1'b1;
                            r_SDA     <= i_data_in;
                            r_ST_main <= WRITE_D;
                        end
                    WRITE_D:
                        begin
                            r_SCL     <= 1'b0;
                            r_SDA     <= i_data_in;
                            r_ST_main <= IDLE;
                        end
                    STOP_A:
                        begin
                            r_SCL     <= 1'b0;
                            r_SDA     <= 1'b0;
                            r_ST_main <= STOP_B;
                        end
                    STOP_B:
                        begin
                            r_SCL     <= 1'b1;
                            r_SDA     <= 1'b0;
                            r_ST_main <= STOP_C;
                        end
                    STOP_C:
                        begin
                            r_SCL     <= 1'b1;
                            r_SDA     <= 1'b1;
                            r_ST_main <= STOP_D;
                        end
                    STOP_D:
                        begin
                            r_SCL     <= 1'b1;
                            r_SDA     <= 1'b1;
                            r_ST_main <= IDLE;
                        end
                    READ_A:
                        begin
                            r_SCL          <= 1'b0;
                            r_data_out     <= r_data_out;
                            r_ST_main      <= READ_B;
                        end
                    READ_B:
                        begin
                            r_SCL          <= 1'b1;
                            r_data_out     <= io_SDA;
                            r_ST_main      <= READ_C;
                        end
                    READ_C:
                        begin
                            r_SCL          <= 1'b1;
                            r_data_out     <= io_SDA;
                            r_ST_main      <= READ_D;
                        end
                    READ_D:
                        begin
                            r_SCL          <= 1'b0;
                            r_data_out     <= r_data_out;
                            r_ST_main      <= IDLE;
                        end
                    endcase
                end
        end
    assign io_SDA = r_SDA;
    assign o_SCL = r_SCL;
    assign o_data_out = r_data_out;


endmodule