// Agent contractor in project cnp

/* Initial beliefs and rules */

received_all_proposals(ContractId,NParticipants) :-
    .count(propose(ContractId,_),NProposed) &
    .count(refuse(ContractId),NRefused) &
    NParticipants = NProposed + NRefused
    .

time_spent(ContractID,Time) :-
	.nano_time(CurrTime) &
	start_time(ContractID,StartTime) &
	Time = (CurrTime - StartTime) / 1000000000
	.

cnp_deadline(4000).

id(ContractID) :-
	.my_name(Name) &
	.substring(Id,Name,10) &
	.term2string(ContractID,Id)
	.

/* Initial goals */

!start.

/* Plans */

+!start
	: id(ContractID)
	<-	.df_register("initiator");
		.print("Started contract ",ContractID);
		.wait(1000);
		.nano_time(StartTime);
		+start_time(ContractID,StartTime);
        !cnp(ContractID);
		.

@cnp_hire
+!cnp(ContractID)
    <-  !call_participants(ContractID,Participants);
        ?cnp_deadline(Deadline);
        .wait(received_all_proposals(ContractID,.length(Participants)),Deadline,_);
        !pick_winner(ContractID,Winner,LoserProposals);
		!reject(ContractID,LoserProposals);
        !accept(ContractID,Winner);
		.wait(10000);
		!check_done(ContractID);
		.

+finished(ContractID)[source(Winner)]
	<-	!print_time(ContractID);
        .

+!check_done(ContractID) : finished(ContractID).
+!check_done(ContractID)
	<-	.print("Contract ",ContractID," failed!");
		+failed(ContractID);
		.


+!call_participants(ContractID,Participants)
    <-  .df_search("participant",Participants);
		.send(Participants,tell,cfp(ContractID))
		.

+!pick_winner(ContractID,Winner,LoserProposals)
    :   .findall(proposal(Offer,Agent),propose(ContractID,Offer)[source(Agent)],Proposals) &
        Proposals \== []
    <-  .min(Proposals,proposal(WinnerOffer,Winner));
        .delete(proposal(WinnerOffer,Winner),Proposals,LoserProposals);
        .
+!pick_winner(_,_,none).

+!reject(ContractID,LoserProposals)
    <-  for ( .member(proposal(Offer,Loser),LoserProposals) ) {
			.send(Loser,tell,reject_proposal(ContractID));
			-propose(ContractID,Offer)[source(Loser)];
		}
        .

+!accept(ContractID,Winner)
    <-  .send(Winner,tell,accept_proposal(ContractID));
		-propose(ContractID,_)[source(Winner)];
        .

+!print_time(ContractID)
	<-	?time_spent(ContractID,Time);
		.print("Time spent on contract ",ContractID," = ",Time);
		.

