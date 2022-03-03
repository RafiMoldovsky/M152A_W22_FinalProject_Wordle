module word_db (input [24:0] word, output wire in_db);

//Bloom filter storing 100 words in 256 bits with 2 hash functions
// ['gazer', 'radio', 'inbox', 'prune', 'heath', 'humid', 'sandy', 'waver', 'canon', 'power']
// ['tangy', 'spoil', 'spank', 'penny', 'scrub', 'islet', 'flame', 'abase', 'onset', 'wheat']
// ['dicey', 'glove', 'serum', 'cavil', 'rivet', 'happy', 'mercy', 'crime', 'aloft', 'gland']
// ['loose', 'heave', 'nudge', 'green', 'diver', 'dopey', 'phony', 'place', 'shrug', 'pinky']
// ['civil', 'thank', 'elegy', 'quite', 'enact', 'taunt', 'ionic', 'ralph', 'dying', 'reset']
// ['widow', 'stuff', 'viral', 'rarer', 'serif', 'solve', 'email', 'gruff', 'drain', 'thick']
// ['still', 'nadir', 'shied', 'liken', 'fever', 'cable', 'tweed', 'belle', 'shrub', 'sadly']
// ['spire', 'giddy', 'credo', 'enema', 'spray', 'cater', 'wedge', 'steel', 'juicy', 'gauge']
// ['bawdy', 'scald', 'pulse', 'fewer', 'asset', 'glass', 'scorn', 'dryer', 'mucus', 'knock']
// ['axiom', 'attic', 'pulpy', 'newer', 'eager', 'stole', 'grape', 'truly', 'woken', 'chant']

localparam [7:0] hash_params [0:1] [0:4] = {
{8'h0024, 8'h0048, 8'h00ae, 8'h00d8, 8'h0023},
{8'h007f, 8'h00f3, 8'h00d0, 8'h001c, 8'h00ba}
};

localparam [255:0] bloom_filter = {
16'b101011000100101,
16'b110011101110011,
16'b011110111101111,
16'b010010111010111,
16'b001101001000110,
16'b011001110100110,
16'b110001101101010,
16'b111110111101000,
16'b011011001101011,
16'b001001100001110,
16'b001101100100000,
16'b110101101111110,
16'b101011100110010,
16'b010111011111011,
16'b010111011111110,
16'b011010000011000
};

wire [7:0] hash_table [0:1][0:4];

wire [7:0] hash [0:1];

wire [0:1] in_db_i;

genvar i,j;
generate
for (i = 0 ; i < 2 ; i = i + 1) begin : which_hash
for (j = 0; j < 5; j = j + 1) begin : which_letter
assign hash_table[i][j] = hash_params[i][j] * word[5*j + 4:5*j];
end
assign hash[i] = hash_table[i][0] + hash_table[i][1] + hash_table[i][2] + hash_table[i][3] + hash_table[i][4];
assign in_db_i[i] = bloom_filter[hash[i]];
end
endgenerate

assign in_db = &in_db_i;

endmodule
