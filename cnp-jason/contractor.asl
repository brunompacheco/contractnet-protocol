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


/* Initial goals */

!register.

/* Plans */

+!register <- .df_register("initiator").

@start_cnp
+id(ContractID)
    <-  .print("CNP started");
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
		.print("Losers = ",LoserProposals);
        !reject(ContractID,LoserProposals);
        !accept(ContractID,Winner);
        .wait({+finished(ContractID)[source(Winner)]},1000);
		!print_time(ContractID);
        -finished(ContractID)[source(Winner)];
        .
-!cnp(ContractID)[error(wait_timeout),source(self)] : true
	<-	.print("Contract ",ContractID," failed!");
		.
		
+!call_participants(ContractID,Participants)
    <-  .df_search("participant",Participants);
		.send(Participants,tell,cfp(ContractID))
		.

+!pick_winner(ContractID,Winner,LoserProposals)
    :   .findall(proposal(Offer,Agent),propose(ContractID,Offer)[source(Agent)],Proposals) &
        Proposals \== []
    <-  .print("Proposals received = ",Proposals);
        .min(Proposals,proposal(WinnerOffer,Winner));
        .print("Winner = ",Winner,"; Offer = ",WinnerOffer);
        .delete(proposal(WinnerOffer,Winner),Proposals,LoserProposals);
        .
+!pick_winner(_,_,none).

+!reject(ContractID,LoserProposals)
    <-  for ( .member(proposal(_,Loser),LoserProposals) ) {
			.send(Loser,tell,reject_proposal(ContractID));
		}
        .

+!accept(ContractID,Winner)
    <-  .send(Winner,tell,accept_proposal(ContractID));
        .

+!print_time(ContractID)
	<-	?time_spent(ContractID,Time);
		.print("Time spent on contract ",ContractID," = ",Time);
		.
