// Agent participant in project cnp

/* Initial beliefs and rules */

price(X) :- .random(R) & X = (10*R) + 100.

/* Initial goals */

!register.

/* Plans */

+!register
    <-  .df_register("participant");
        .df_subscribe("initiator");
        .

@answer_cfp
+cfp(ContractID)[source(Agent)]
    :   provider(Agent,"initiator") &
        price(Offer)
    <-  +proposal(ContractID,Offer,Agent);
        .send(Agent,tell,propose(ContractID,Offer));
		.

@lost_cfp
+reject_proposal(ContractID)[source(Agent)]
    <-  -proposal(ContractID,Offer,Agent);
        .

@won_cfp
+accept_proposal(ContractID)[source(Agent)]
    :   proposal(ContractID,Offer,Agent)
    <-  -proposal(ContractID,Offer,Agent);
		.send(Agent,tell,finished(ContractID));
        .
