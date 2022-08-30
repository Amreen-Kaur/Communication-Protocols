module eeprom_top
  (
 input clk,
 input rst,
 input newd,
 input ack,
 input wr,   
 output scl,
 inout sda,
 input [7:0] wdata,
 input [6:0] addr, /////8-bit  7-bit : addr 1-bit : mode
 output reg [7:0] rdata,
 output reg done
  );
  
 reg sda_en = 0;
  
 reg sclt, sdat, donet; 
 reg [7:0] rdatat; 
 reg [7:0] addrt;
 
  
parameter idle = 0, check_wr = 1, wstart = 2, wsend_addr = 3, waddr_ack = 4, 
                wsend_data = 5, wdata_ack = 6, wstop = 7, rsend_addr = 8, 
                raddr_ack = 9, rsend_data = 10,
                rdata_ack = 11, rstop = 12 ;
  
  
  
  
  reg [3:0] state;
  reg sclk_ref = 0;
  integer count = 0;
  integer i = 0;
  
  ////100 M / 400 K = N
  ///N/2
  
  
  always@(posedge clk)
    begin
      if(count <= 9) 
        begin
           count <= count + 1;     
        end
      else
         begin
           count     <= 0; 
           sclk_ref  <= ~sclk_ref;
         end	      
    end
  
  
  
  always@(posedge sclk_ref, posedge rst)
    begin 
      if(rst == 1'b1)
         begin
           sclt  <= 1'b0;
           sdat  <= 1'b0;
           donet <= 1'b0;
         end
       else begin
         case(state)
           idle : 
           begin
              sdat <= 1'b0;
              done <= 1'b0;
              sda_en  <= 1'b1;
              sclt <= 1'b1;
              sdat <= 1'b1;
             if(newd == 1'b1) 
                state  <= wstart;
             else 
                 state <= idle;         
           end
         
            wstart: 
            begin
              sdat  <= 1'b0;
              sclt  <= 1'b1;
              state <= check_wr;
              addrt <= {addr,wr};
            end
            
            
            
            check_wr: begin
                ///addr remain same for both write and read
              if(wr == 1'b1) 
                 begin
                 state <= wsend_addr;
                 sdat <= addrt[0];
                 i <= 1;
                 end
               else 
                 begin
                 state <= rsend_addr;
                 sdat <= addrt[0];
                 i <= 1;
                 end
            end