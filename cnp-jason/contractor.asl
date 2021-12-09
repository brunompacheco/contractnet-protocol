// Agent contractor in project cnp

/* Initial beliefs and rules */

received_all_proposals(ContractId,NParticipants) :-
    .count(propose(ContractId,_),NProposed) &
    .count(refuse(ContractId),NRefused) &
    NParticipants = NProposed + NRefused
    .

cnp_deadline(4000).

/* Initial goals */

!register.
!cnp(1,1).

/* Plans */

+!register <- .df_register("initiator").

@cnp_hire
+!cnp(ContractID,Task)
    <-  +contract(ContractID,open);
        !call_participants(ContractID,Task,Participants);
        ?cnp_deadline(Deadline);
        .wait(received_all_proposals(ContractID,.length(Participants)),Deadline,_);
        !pick_winner(ContractID,Winner,Losers);
        !reject(ContractID,Losers);
        !accept(ContractID,Winner);
        .wait({+finished(ContractID)[source(Winner)]});
        +contract(ContractID,closed);
        -finished(ContractID)[source(Winner)];
        .stopMAS;
        .

+!call_participants(ContractID,Task,Participants)
    <-  .wait(100);  // wait for participants to register
    	.df_search("participant",Participants);
		.send(Participants,tell,cfp(ContractID,Task))
		.

+!pick_winner(ContractID,Winner,Losers)
    :   .findall(proposal(Offer,Agent),propose(ContractID,Offer)[source(Agent)],Proposals) &
        Proposals \== []
    <-  .print("Proposals received = ",Proposals);
        .min(Proposals,proposal(WinnerOffer,Winner));
        .print("Winner = ",Winner,"; Offer = ",WinnerOffer);
        .delete(proposal(WinnerOffer,Winner),Proposals,Losers);
        .
+!pick_winner(_,_,none).

+!reject(_,[]) .
+!reject(ContractID,[proposal(_,Loser)|RemainingLosers])
    <-  .send(Loser,tell,reject_proposal(ContractID));
        !reject(ContractID,RemainingLosers)
        .

+!accept(ContractID,Winner)
    <-  .send(Winner,tell,accept_proposal(ContractID));
        .
