// Agent participant in project cnp

/* Initial beliefs and rules */

price(Task,X) :- .random(R) & X = (10*R) + 100.

task_duration(Task,Time) :- .random(R) & Time = 500 + (R*500).

/* Initial goals */

!register.

/* Plans */

+!register
    <-  .df_register("participant");
        .df_subscribe("initiator");
        .

@answer_cfp
+cfp(ContractID,Task)[source(Agent)]
    :   provider(Agent,"initiator") &
        price(Task,Offer)
    <-  +proposal(ContractID,Task,Offer,Agent);
        .send(Agent,tell,propose(ContractID,Offer));
		.

@lost_cfp
+reject_proposal(ContractID)[source(Agent)]
    <-  -proposal(ContractID,Task,Offer,Agent);
        .

@won_cfp
+accept_proposal(ContractID)[source(Agent)]
    :   proposal(ContractID,Task,Offer,Agent) &
        task_duration(Task,Time)
    <-  -proposal(ContractID,Task,Offer,Agent);
        .df_deregister(participant);
        .wait(Time);
        .send(Agent,tell,finished(ContractID));
        !register;
        .
