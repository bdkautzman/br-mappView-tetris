
PROGRAM _INIT
	// I block = 00FFFF (0, 255, 255) 	Turquoise
	// J block = 0000AC (0, 0, 172) 	Blue
	// L block = FF7800 (255, 120,0) 	Orange
	// O block = FFFF00 (255, 255, 0) 	Yellow
	// S block = 00FF00 (0, 255, 0) 	Green
	// T block = CD00CD (205, 0, 205) 	Purple
	// Z block = FF0000 (255, 0, 0) 	Red
	
	TON_GameTick.PT := T#1000ms;
	
	CurrentX := 25;
	CurrentY := 25;
	brsstrcat(ADR(Transform),ADR('[{"select":"#Board","duration":10,"display":true,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T1","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T2","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T3","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T4","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T5","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T6","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T7","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T8","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T9","duration":10,"display":false,"translate":[25,25]},')); 
	brsstrcat(ADR(Transform),ADR('{"select":"T10","duration":10,"display":false,"translate":[25,25]}]'));
	
END_PROGRAM

PROGRAM _CYCLIC
	
	IF TON_GameTick.Q THEN
		RegDown := TRUE;
		TON_GameTick.IN := FALSE;
	ELSIF StartGame THEN
		TON_GameTick.IN := TRUE;
	ELSE
		TON_GameTick.IN := FALSE;
	END_IF
	
	IF ResetGame AND TetrisState <> TET_GAME_OVER THEN
		ResetGame := FALSE;
		TetrisState := TET_INIT_BOARD;
	END_IF
	
	CASE TetrisState OF
		
		TET_INIT_BOARD:
			// Reset game flags and score
			GameOverVis := FALSE;
			Collision 	:= FALSE;
			Score		:= 0;
			
			// Reset user inputs
			MoveRight 	:= FALSE;
			MoveLeft 	:= FALSE;
			RegDown 	:= FALSE;
			DownMove 	:= FALSE;
			
			// Reset board and pieces
			brsmemset(ADR(GameBoard),0,SIZEOF(GameBoard));
			brsmemset(ADR(PieceCur),0,SIZEOF(PieceCur));
			brsmemset(ADR(PieceNext),0,SIZEOF(PieceNext));
			
			// Reset available tiles
			FOR i := 1 TO MAX_NUM_TILES DO
				TilesAvailable[i-1] := i;
			END_FOR
			
			// Print background + invisble tiles
			brsmemset(ADR(Transform),0,SIZEOF(Transform));
			brsstrcat(ADR(Transform),ADR('[{"select":"#Board","duration":10,"display":true,"translate":[25,25]},'));
			FOR i := 1 TO MAX_NUM_TILES DO
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsstrcat(ADR(Transform),ADR('{"select":"#T'));
				brsitoa(i,ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR('","duration":10,"display":false,"fill":1,"translate":[25,25]},'));
			END_FOR
			brsmemmove(ADR(Transform)+brsstrlen(ADR(Transform))-1,ADR(']'),SIZEOF(']'));
			
			// Print on deck invisible tiles
			brsmemset(ADR(TransformOnDeck),0,SIZEOF(TransformOnDeck));
			brsstrcat(ADR(TransformOnDeck),ADR('['));
			FOR i := 1 TO 4 DO
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR('{"select":"#T'));
				brsitoa(i,ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR('","duration":10,"display":false,"fill":1,"translate":[12,12]},'));
			END_FOR
			brsmemmove(ADR(TransformOnDeck)+brsstrlen(ADR(TransformOnDeck))-1,ADR(']'),SIZEOF(']'));
			
			// Print in hole invisible tiles
			brsmemset(ADR(TransformInHole),0,SIZEOF(TransformInHole));
			brsstrcat(ADR(TransformInHole),ADR('['));
			FOR i := 1 TO 4 DO
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR('{"select":"#T'));
				brsitoa(i,ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR('","duration":10,"display":false,"fill":1,"translate":[12,12]},'));
			END_FOR
			brsmemmove(ADR(TransformInHole)+brsstrlen(ADR(TransformInHole))-1,ADR(']'),SIZEOF(']'));
			
			DelayTime := T#100ms;
			
			NextTetrisState := TET_WAIT_START;	
			TetrisState 	:= TET_PRINT_DELAY;
			
		TET_WAIT_START:
			IF StartGame THEN
				TetrisState := TET_GEN_PIECE;
			END_IF
			
		TET_GEN_PIECE:
			ShapeState := rand_interval(0,6);
			brsmemcpy(ADR(PieceNext[0]),ADR(PieceNext[1]),SIZEOF(PieceNext[0]));
			brsmemcpy(ADR(PieceNext[1]),ADR(PieceNext[2]),SIZEOF(PieceNext[1]));
			
			CASE ShapeState OF
				
				I_BLOCK:
					PieceNext[2].CoR.X := 4.5;
					PieceNext[2].CoR.Y := 1;
					
					PieceNext[2].Tiles[0].X := 3;
					PieceNext[2].Tiles[0].Y := 1;
					
					PieceNext[2].Tiles[1].X := 4;
					PieceNext[2].Tiles[1].Y := 1;
					
					PieceNext[2].Tiles[2].X := 5;
					PieceNext[2].Tiles[2].Y := 1;
					
					PieceNext[2].Tiles[3].X := 6;
					PieceNext[2].Tiles[3].Y := 1;
					
				J_BLOCK:
					PieceNext[2].CoR.X := 4;
					PieceNext[2].CoR.Y := 1;
					
					PieceNext[2].Tiles[0].X := 3;
					PieceNext[2].Tiles[0].Y := 0;
					
					PieceNext[2].Tiles[1].X := 3;
					PieceNext[2].Tiles[1].Y := 1;
					
					PieceNext[2].Tiles[2].X := 4;
					PieceNext[2].Tiles[2].Y := 1;
					
					PieceNext[2].Tiles[3].X := 5;
					PieceNext[2].Tiles[3].Y := 1;
					
				L_BLOCK:
					PieceNext[2].CoR.X := 4;
					PieceNext[2].CoR.Y := 1;
					
					PieceNext[2].Tiles[0].X := 3;
					PieceNext[2].Tiles[0].Y := 1;
					
					PieceNext[2].Tiles[1].X := 4;
					PieceNext[2].Tiles[1].Y := 1;
					
					PieceNext[2].Tiles[2].X := 5;
					PieceNext[2].Tiles[2].Y := 1;
					
					PieceNext[2].Tiles[3].X := 5;
					PieceNext[2].Tiles[3].Y := 0;
					
				O_BLOCK:
					PieceNext[2].CoR.X := 4.5;
					PieceNext[2].CoR.Y := 0.5;
					
					PieceNext[2].Tiles[0].X := 4;
					PieceNext[2].Tiles[0].Y := 0;
					
					PieceNext[2].Tiles[1].X := 4;
					PieceNext[2].Tiles[1].Y := 1;
					
					PieceNext[2].Tiles[2].X := 5;
					PieceNext[2].Tiles[2].Y := 0;
					
					PieceNext[2].Tiles[3].X := 5;
					PieceNext[2].Tiles[3].Y := 1;
					
				S_BLOCK:
					PieceNext[2].CoR.X := 4;
					PieceNext[2].CoR.Y := 1;
					
					PieceNext[2].Tiles[0].X := 3;
					PieceNext[2].Tiles[0].Y := 1;
					
					PieceNext[2].Tiles[1].X := 4;
					PieceNext[2].Tiles[1].Y := 1;
					
					PieceNext[2].Tiles[2].X := 4;
					PieceNext[2].Tiles[2].Y := 0;
					
					PieceNext[2].Tiles[3].X := 5;
					PieceNext[2].Tiles[3].Y := 0;
					
				T_BLOCK:
					PieceNext[2].CoR.X := 4;
					PieceNext[2].CoR.Y := 1;
					
					PieceNext[2].Tiles[0].X := 3;
					PieceNext[2].Tiles[0].Y := 1;
					
					PieceNext[2].Tiles[1].X := 4;
					PieceNext[2].Tiles[1].Y := 1;
					
					PieceNext[2].Tiles[2].X := 5;
					PieceNext[2].Tiles[2].Y := 1;
					
					PieceNext[2].Tiles[3].X := 4;
					PieceNext[2].Tiles[3].Y := 0;
					
				Z_BLOCK:
					PieceNext[2].CoR.X := 4;
					PieceNext[2].CoR.Y := 1;
					
					PieceNext[2].Tiles[0].X := 3;
					PieceNext[2].Tiles[0].Y := 0;
					
					PieceNext[2].Tiles[1].X := 4;
					PieceNext[2].Tiles[1].Y := 0;
					
					PieceNext[2].Tiles[2].X := 4;
					PieceNext[2].Tiles[2].Y := 1;
					
					PieceNext[2].Tiles[3].X := 5;
					PieceNext[2].Tiles[3].Y := 1;
					
			END_CASE
			
			PieceNext[2].Shape := ShapeState;
			
			// Generate 3 shapes if game has just started
			IF PieceNext[0].CoR.X = 0 AND PieceNext[0].CoR.Y = 0 THEN
				TetrisState := TET_GEN_PIECE;
			ELSE
				TetrisState := TET_PRINT_IN_THE_HOLE;
			END_IF
		
		TET_PRINT_IN_THE_HOLE:
			// Print piece
			brsmemset(ADR(TransformInHole),0,SIZEOF(TransformInHole));
			brsstrcat(ADR(TransformInHole),ADR('['));
			FOR i := 0 TO 3 DO
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR('{"select":"#T'));
				brsitoa(i+1,ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR('","duration":10,"display":true,"fill":'));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceNext[2].Shape,ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(',"translate":['));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceNext[2].Tiles[i].X*30 +40,ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(','));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceNext[2].Tiles[i].Y*30 +25,ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(TmpStr));
				brsstrcat(ADR(TransformInHole),ADR(']},'));
			END_FOR
			brsmemmove(ADR(TransformInHole)+brsstrlen(ADR(TransformInHole))-1,ADR(']'),SIZEOF(']'));
			
			TetrisState := TET_PRINT_ON_DECK;
			
		TET_PRINT_ON_DECK:
			// Print piece
			brsmemset(ADR(TransformOnDeck),0,SIZEOF(TransformOnDeck));
			brsstrcat(ADR(TransformOnDeck),ADR('['));
			FOR i := 0 TO 3 DO
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR('{"select":"#T'));
				brsitoa(i+1,ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR('","duration":10,"display":true,"fill":'));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceNext[1].Shape,ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(',"translate":['));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceNext[1].Tiles[i].X*30 + 40,ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(','));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceNext[1].Tiles[i].Y*30 +25,ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(TmpStr));
				brsstrcat(ADR(TransformOnDeck),ADR(']},'));
			END_FOR
			brsmemmove(ADR(TransformOnDeck)+brsstrlen(ADR(TransformOnDeck))-1,ADR(']'),SIZEOF(']'));
			
			TetrisState := TET_GEN_PIECE_LOC_CHECK;
			
		TET_GEN_PIECE_LOC_CHECK:
			
			FOR i := 0 TO 3 DO
				IF GameBoard[PieceNext[0].Tiles[i].X,PieceNext[0].Tiles[i].Y] <> 0 THEN
					TetrisState := TET_GAME_OVER;
					EXIT;
				ELSE
					TetrisState := TET_PRINT_PIECE;
				END_IF
			END_FOR
			
		TET_PRINT_PIECE:
			// Copy
			brsmemcpy(ADR(PieceCur),ADR(PieceNext[0]),SIZEOF(PieceCur));
			
			// Print piece
			brsmemset(ADR(Transform),0,SIZEOF(Transform));
			brsstrcat(ADR(Transform),ADR('['));
			FOR i := 0 TO 3 DO
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsstrcat(ADR(Transform),ADR('{"select":"#T'));
				brsitoa(TilesAvailable[i],ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR('","duration":10,"display":true,"fill":'));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceCur.Shape,ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(',"translate":['));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceCur.Tiles[i].X*30 +25,ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(','));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceCur.Tiles[i].Y*30 +25,ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(']},'));
			END_FOR
			brsmemmove(ADR(Transform)+brsstrlen(ADR(Transform))-1,ADR(']'),SIZEOF(']'));
			
			FOR i := 0 TO 249 DO
				brsmemcpy(ADR(LogGenString[i]),ADR(Transform) + 80*i,80);
			END_FOR
			
			DelayTime := T#100ms;
			
			NextTetrisState := TET_WAIT_INPUT;	
			TetrisState 	:= TET_PRINT_DELAY;
			
		TET_WAIT_INPUT:
			IF RegDown THEN
				RegDown := FALSE;
				DownMove := TRUE;
				DelayTime := T#60ms;
				TetrisState := TET_REG_DOWN;
			ELSIF MoveLeft THEN
				DelayTime := T#60ms;
				TetrisState := TET_MOVE_LEFT;
			ELSIF MoveRight THEN
				DelayTime := T#60ms;
				TetrisState := TET_MOVE_RIGHT;
			ELSIF RotClock THEN
				DelayTime := T#60ms;
				TetrisState := TET_ROT_CLOCK;
			ELSIF RotCounter THEN
				DelayTime := T#60ms;
				TetrisState := TET_ROT_COUNTER;
			ELSIF FastDown THEN
				DownMove := TRUE;
				DelayTime := T#30ms;
				TetrisState := TET_FAST_DOWN;
			END_IF
		
		TET_MOVE_RIGHT:
			// Increment each tile x position + 1
			brsmemcpy(ADR(PieceNext[0]),ADR(PieceCur),SIZEOF(PieceNext[0]));
			PieceNext[0].CoR.X := PieceNext[0].CoR.X + 1;
			FOR i := 0 TO 3 DO
				PieceNext[0].Tiles[i].X := PieceNext[0].Tiles[i].X + 1;
			END_FOR
			
			TetrisState := TET_CHECK_COLLISION;			
		
		TET_MOVE_LEFT:
			// Increment each tile x position + 1
			brsmemcpy(ADR(PieceNext[0]),ADR(PieceCur),SIZEOF(PieceNext[0]));
			PieceNext[0].CoR.X := PieceNext[0].CoR.X - 1;
			FOR i := 0 TO 3 DO
				PieceNext[0].Tiles[i].X := PieceNext[0].Tiles[i].X - 1;
			END_FOR
			
			TetrisState := TET_CHECK_COLLISION;	
			
		TET_ROT_CLOCK:
			
			FOR i := 0 TO 3 DO
				PieceNext[0].Tiles[i].X := REAL_TO_INT(PieceCur.CoR.X + PieceCur.CoR.Y  - PieceCur.Tiles[i].Y);
				PieceNext[0].Tiles[i].Y := REAL_TO_INT(PieceCur.Tiles[i].X + PieceCur.CoR.Y - PieceCur.CoR.X);
			END_FOR
			
			TetrisState := TET_CHECK_COLLISION;
				
		TET_ROT_COUNTER:
			FOR i := 0 TO 3 DO
				PieceNext[0].Tiles[i].X := REAL_TO_INT(PieceCur.Tiles[i].Y + PieceCur.CoR.X - PieceCur.CoR.Y);
				PieceNext[0].Tiles[i].Y := REAL_TO_INT(PieceCur.CoR.Y + PieceCur.CoR.X  - PieceCur.Tiles[i].X);
			END_FOR
			
			TetrisState := TET_CHECK_COLLISION;
			
		TET_FAST_DOWN:
			// Increment each tile y position + 1
			brsmemcpy(ADR(PieceNext[0]),ADR(PieceCur),SIZEOF(PieceNext[0]));
			PieceNext[0].CoR.Y := PieceNext[0].CoR.Y + 1;
			FOR i := 0 TO 3 DO
				PieceNext[0].Tiles[i].Y := PieceNext[0].Tiles[i].Y + 1;
			END_FOR
			
			TetrisState := TET_CHECK_COLLISION;
		
		TET_REG_DOWN:
			// Increment each tile y position + 1
			brsmemcpy(ADR(PieceNext[0]),ADR(PieceCur),SIZEOF(PieceNext[0]));
			PieceNext[0].CoR.Y := PieceNext[0].CoR.Y + 1;
			FOR i := 0 TO 3 DO
				PieceNext[0].Tiles[i].Y := PieceNext[0].Tiles[i].Y + 1;
			END_FOR
			
			TetrisState := TET_CHECK_COLLISION;	
			
		TET_CHECK_COLLISION:
			Collision := FALSE;
			FOR i := 0 TO 3 DO
				// Gameboard index needs to be checked only if index is within array bounds
				IF PieceNext[0].Tiles[i].Y = 20 OR PieceNext[0].Tiles[i].X = -1 OR PieceNext[0].Tiles[i].X = 10 THEN
					Collision := TRUE;
					EXIT;
				ELSIF GameBoard[PieceNext[0].Tiles[i].X,PieceNext[0].Tiles[i].Y] <> 0 THEN
					Collision := TRUE;
					EXIT;
				END_IF
			END_FOR
			
			IF Collision THEN
				IF DownMove THEN
					FOR i := 0 TO 3 DO
						GameBoard[PieceCur.Tiles[i].X,PieceCur.Tiles[i].Y] := TilesAvailable[0];
						FOR w := 0 TO 169 DO
							TilesAvailable[w] := TilesAvailable[w+1];
						END_FOR
					END_FOR
					TetrisState := TET_CHECK_FULL_ROW;
				ELSE
					TetrisState := TET_WAIT_INPUT;
				END_IF
			ELSE
				TetrisState := TET_PRINT_MOVE;
			END_IF
			
			DownMove := FALSE;
			
		TET_PRINT_MOVE:
			// Copy
			brsmemcpy(ADR(PieceCur),ADR(PieceNext[0]),SIZEOF(PieceCur));
			
			// Print piece
			brsmemset(ADR(Transform),0,SIZEOF(Transform));
			brsstrcat(ADR(Transform),ADR('['));
			FOR i := 0 TO 3 DO
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsstrcat(ADR(Transform),ADR('{"select":"#T'));
				brsitoa(TilesAvailable[i],ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR('","duration":10,"display":true,"translate":['));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceCur.Tiles[i].X*30 +25,ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(','));
				brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
				brsitoa(PieceCur.Tiles[i].Y*30 +25,ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(TmpStr));
				brsstrcat(ADR(Transform),ADR(']},'));
			END_FOR
			brsmemmove(ADR(Transform)+brsstrlen(ADR(Transform))-1,ADR(']'),SIZEOF(']'));
			
			brsmemcpy(ADR(LogStr2),ADR(LogStr1),SIZEOF(LogStr1));
			brsmemcpy(ADR(LogStr1),ADR(LogStr),SIZEOF(LogStr));
			
			
			NextTetrisState := TET_WAIT_INPUT;	
			TetrisState 	:= TET_PRINT_DELAY;
		
		TET_CHECK_FULL_ROW:
			// Loop through game board to find filled rows
			NumRowsCleared := 0;
			FOR i := 0 TO 19 DO
				FOR k := 0 TO 9 DO
					IF GameBoard[k,i] = 0 THEN
						EXIT;
					ELSIF k = 9 THEN
						NumRowsCleared := NumRowsCleared + 1;
						RowsToDelete[i] := TRUE;
					END_IF
				END_FOR
			END_FOR
			
			IF NumRowsCleared <> 0 THEN
				TetrisState := TET_DELETE_ROW;
			ELSE
				TetrisState := TET_GEN_PIECE;
			END_IF
			
		TET_DELETE_ROW:
			brsmemset(ADR(Transform),0,SIZEOF(Transform));
			brsstrcat(ADR(Transform),ADR('['));
			FOR k := 0 TO 19 DO
				IF RowsToDelete[k] THEN
					FOR i := 0 TO 9 DO
						brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
						brsstrcat(ADR(Transform),ADR('{"select":"#T'));
						brsitoa(GameBoard[i,k],ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR('","duration":10,"display":false},'));
						TilesDeleted[NumTilesDeleted] := GameBoard[i,k];
						NumTilesDeleted := NumTilesDeleted + 1;
					END_FOR
				END_IF
			END_FOR
			brsmemmove(ADR(Transform)+brsstrlen(ADR(Transform))-1,ADR(']'),SIZEOF(']'));
			
			// Clear finished rows from GameBoard
			FOR i := 1 TO 19 DO
				IF RowsToDelete[i] THEN
					FOR k := i TO 1 BY -1 DO
						FOR w := 0 TO 9 DO
							GameBoard[w,k] := GameBoard[w,k-1];
						END_FOR
					END_FOR
					RowsToDelete[i] := FALSE;
				END_IF
			END_FOR
			
			// Add deleted tiles to available tiles array
			FOR i := 0 TO (NumTilesDeleted - 1) DO
				FOR w := 170 TO 1 BY -1 DO
					TilesAvailable[w] := TilesAvailable[w-1];
				END_FOR
				TilesAvailable[0] := TilesDeleted[i];
			END_FOR
			NumTilesDeleted := 0;
			brsmemset(ADR(TilesDeleted),0,SIZEOF(TilesDeleted));
			
			IF NumRowsCleared = 4 THEN
				Score := Score + 50;
			ELSE
				Score := Score + NumRowsCleared*10;
			END_IF
			NumRowsCleared := 0;
			
			DelayTime := T#100ms;
			
			NextTetrisState := TET_SHIFT_DOWN;	
			TetrisState 	:= TET_PRINT_DELAY;
				
		TET_SHIFT_DOWN:
			brsmemset(ADR(Transform),0,SIZEOF(Transform));
			brsstrcat(ADR(Transform),ADR('['));
			FOR i := 0 TO 9 DO
				FOR k := 0 TO 19 DO
					IF GameBoard[i,k] <> 0 THEN
						brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
						brsstrcat(ADR(Transform),ADR('{"select":"#T'));
						brsitoa(GameBoard[i,k],ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR('","duration":10,"display":true,"translate":['));
						brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
						brsitoa(i*30 + 25,ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR(','));
						brsmemset(ADR(TmpStr),0,SIZEOF(TmpStr));
						brsitoa(k*30 + 25,ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR(TmpStr));
						brsstrcat(ADR(Transform),ADR(']},'));
					END_IF
				END_FOR
			END_FOR
			brsmemmove(ADR(Transform)+brsstrlen(ADR(Transform))-1,ADR(']'),SIZEOF(']'));
			
			DelayTime := T#100ms;
			
			NextTetrisState := TET_GEN_PIECE;	
			TetrisState 	:= TET_PRINT_DELAY;
			
		TET_GAME_OVER:
			GameOverVis := TRUE;
			StartGame := FALSE;
			
			IF ResetGame THEN
				StartGame := TRUE;
				ResetGame := FALSE;
				TetrisState := TET_INIT_BOARD;
			END_IF
		
		TET_PRINT_DELAY:
			TON_Print.PT := DelayTime;
			TON_Print.IN := TRUE;
			
			IF TON_Print.Q THEN
				TON_Print.IN := FALSE;
				TetrisState := NextTetrisState;	
			END_IF
		
	END_CASE
	
	// FB Calls
	TON_GameTick();
	TON_Print();
	
	FOR i := 0 TO 249 DO
		brsmemcpy(ADR(LogStr[i]),ADR(Transform) + 80*i,80);
	END_FOR
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

