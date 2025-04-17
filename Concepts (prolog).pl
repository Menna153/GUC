assign_proctors(AllTAs, Quizzes, TeachingSchedule, ProctoringSchedule):- 
						free_schedule(AllTAs, TeachingSchedule, FreeSchedule),
						assign_quizzes(Quizzes, FreeSchedule, ProctoringSchedule).

						
						
free_schedule(AllTAs, TeachingSchedule, FreeSchedule):- 
						getFreeSchedule(AllTAs, TeachingSchedule, FreeSchedule).
					
getFreeSchedule([], FinalAcc, FinalAcc).				
getFreeSchedule([H|T], TeachingSchedule, Result):- 
						freeScheduleHelper(H, TeachingSchedule, FinalAcc),
						getFreeSchedule(T, FinalAcc, Result).
						
freeScheduleHelper(_, [], []).						
freeScheduleHelper(H, [H1|T1], FinalAcc):-
						H = ta(Name, Day_Off),
						H1 = day(DayName, DaySchedule),
						DayName \= Day_Off,
						dayScheduleHelper(Name, DaySchedule, [], Acc),
						reverse(Acc,Acc1),
						Res = day(DayName, Acc1),
						FinalAcc = [Res|T2],
						freeScheduleHelper(H, T1, T2).				
freeScheduleHelper(H, [H1|T1], FinalAcc):-
						H = ta(Name, Day_Off),
						H1 = day(DayName, DaySchedule),
						DayName == Day_Off,
						FinalAcc = [H1|T2],
						freeScheduleHelper(H, T1, T2).
						
dayScheduleHelper(_, [], Acc, Acc).		
dayScheduleHelper(Name, [H|T], Acc1, Acc):- 
						member(Name, H),
						delete(H, Name, H1),
						permutation(H1,H2),
						Acc2 = [H2|Acc1],
						dayScheduleHelper(Name, T, Acc2, Acc).		
dayScheduleHelper(Name, [H|T], Acc1, Acc):- 
						\+ member(Name, H),
						append(H, [Name], H1),
						permutation(H1,H2),
						Acc2 = [H2|Acc1],
						dayScheduleHelper(Name, T, Acc2, Acc).											
					
					
					
assign_quizzes(Quizzes, FreeSchedule, ProctoringSchedule):- 
						getProctoringScheduleHelper(Quizzes, FreeSchedule, [], ProctoringSchedule1),
						reverse(ProctoringSchedule1, ProctoringSchedule).
						
getProctoringScheduleHelper([], _, Acc, Acc).
getProctoringScheduleHelper([H|T], FreeSchedule, Acc, ProctoringSchedule):-
						H = quiz(Course, Day, Slot, Count),
						assign_quiz(H, FreeSchedule, AssignedTAs),
						X = proctors(H, AssignedTAs),
						Acc1 = [X|Acc],
						getNewFreeSchedule(FreeSchedule, Day, Slot, AssignedTAs, [], NewFreeSchedule1),
						reverse(NewFreeSchedule1, NewFreeSchedule),
						getProctoringScheduleHelper(T, NewFreeSchedule, Acc1, ProctoringSchedule).
				
getNewFreeSchedule([], _, _, _, Acc, Acc).			
getNewFreeSchedule([H|T], Day, Slot, AssignedTAs, Acc, NewFreeSchedule):- 
						H = day(DayName, DaySchedule),
						Day \= DayName,
						Acc1 = [H|Acc],
						getNewFreeSchedule(T, Day, Slot, AssignedTAs, Acc1, NewFreeSchedule).
getNewFreeSchedule([H|T], Day, Slot, AssignedTAs, Acc, NewFreeSchedule):- 
						H = day(DayName, DaySchedule),
						Day == DayName,
						changeDaySchedule(DaySchedule, 1, Slot, AssignedTAs, [], NewDaySchedule1),
						reverse(NewDaySchedule1, NewDaySchedule),
						H1 = day(DayName, NewDaySchedule),
						Acc1 = [H1|Acc],
						getNewFreeSchedule(T, Day, Slot, AssignedTAs, Acc1, NewFreeSchedule).
						
changeDaySchedule([], _, _, _, Acc, Acc).								
changeDaySchedule([H|T], C, Slot, AssignedTAs, Acc, NewDaySchedule):- 
						C \= Slot,
						Acc1 = [H|Acc],
						C1 is C+1,
						changeDaySchedule(T, C1, Slot, AssignedTAs, Acc1, NewDaySchedule).
changeDaySchedule([H|T], Slot, Slot, AssignedTAs, Acc, NewDaySchedule):- 
						remove(H, AssignedTAs, H1),
						Acc1 = [H1|Acc],
						C1 is Slot+1,
						changeDaySchedule(T, C1, Slot, AssignedTAs, Acc1, NewDaySchedule).
	
remove([], _, []).
remove([H|T], AssignedTAs, Res):- 
						member(H, AssignedTAs),
						remove(T, AssignedTAs, Res).
remove([H|T], AssignedTAs, [H|T1]):- 
						\+ member(H, AssignedTAs),
						remove(T, AssignedTAs, T1).


						
assign_quiz(Quiz, FreeSchedule, AssignedTAs):-
						Quiz = quiz(_, Day, Slot, Count), 
						getDaySchedule(FreeSchedule, Day, DaySchedule),
						getAvailableTAs(DaySchedule, 1, Slot, List), 
						length(List,N),
						((N = Count, permutation(List, AssignedTAs)); 
						(N > Count, getPermutations(List, Count, AssignedTAs))).	
						
getDaySchedule([H|_], Day, DaySchedule):- H = day(DayName, DaySchedule), DayName = Day.
getDaySchedule([H|T], Day, DaySchedule):- H = day(DayName, _), DayName \= Day, getDaySchedule(T, Day, DaySchedule).

getAvailableTAs([H|_], Slot, Slot, H).							
getAvailableTAs([_|T], C, Slot, List):- C1 is C+1, getAvailableTAs(T, C1, Slot, List).

getPermutations(List, Count, Output):- permutation(List,L), choose(L,0,Count,Output).
choose(_, Count, Count, []).
choose([H|T], C, Count, [H|T1]):- C1 is C+1, choose(T,C1,Count,T1).



						
							
