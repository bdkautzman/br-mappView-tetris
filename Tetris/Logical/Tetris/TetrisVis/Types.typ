
TYPE
	real_coord_typ : 	STRUCT 
		X : REAL;
		Y : REAL;
	END_STRUCT;
	int_coord_typ : 	STRUCT 
		X : INT;
		Y : INT;
	END_STRUCT;
	piece_typ : 	STRUCT 
		Tiles : ARRAY[0..3]OF int_coord_typ;
		CoR : real_coord_typ;
		Shape : shape_enum;
	END_STRUCT;
END_TYPE

(*Enumerations*)

TYPE
	stateTetris_enum : 
		(
		TET_INIT_BOARD,
		TET_WAIT_START,
		TET_GEN_PIECE,
		TET_PRINT_IN_THE_HOLE,
		TET_PRINT_ON_DECK,
		TET_GEN_PIECE_LOC_CHECK,
		TET_PRINT_PIECE,
		TET_WAIT_INPUT,
		TET_MOVE_RIGHT,
		TET_MOVE_LEFT,
		TET_ROT_CLOCK,
		TET_ROT_COUNTER,
		TET_FAST_DOWN,
		TET_REG_DOWN,
		TET_CHECK_COLLISION,
		TET_PRINT_MOVE,
		TET_CHECK_FULL_ROW,
		TET_DELETE_ROW,
		TET_SHIFT_DOWN,
		TET_GAME_OVER,
		TET_PRINT_DELAY
		);
	shape_enum : 
		(
		I_BLOCK := 0,
		J_BLOCK := 1,
		L_BLOCK := 2,
		O_BLOCK := 3,
		S_BLOCK := 4,
		T_BLOCK := 5,
		Z_BLOCK := 6
		);
END_TYPE
