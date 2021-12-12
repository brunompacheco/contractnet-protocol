from random import random

from pade.misc.utility import call_later, display_message
from pade.core.agent import Agent
from pade.acl.aid import AID
from pade.acl.messages import ACLMessage
from pade.behaviours.protocols import FipaContractNetProtocol

class BehaviourParticipant(FipaContractNetProtocol):
    def __init__(self, agent, message=None):
        super().__init__(agent, message=message, is_initiator=False)

    def display(self, msg: str):
        return display_message(self.agent.aid.name, msg)

    def handle_cfp(self, message):
        super().handle_cfp(message)

        # self.display(f"Call for proposals received for contract '{message.content}'")

        answer = message.create_reply()
        answer.set_performative(ACLMessage.PROPOSE)
        answer.set_content(self.agent.price())
        self.agent.send(answer)

    def handle_reject_propose(self, message):
        super().handle_reject_propose(message)

        self.display(f"Proposal rejected for contract '{message.content}'")

    def handle_accept_propose(self, message):
        super().handle_accept_propose(message)

        self.display(f"Proposal accepted for contract '{message.content}'")

        self.do_task(message)

        self.inform_done(message)

    def inform_done(self, message):
        self.display(f"Finished contract '{message.content}'")

        answer = message.create_reply()
        answer.set_performative(ACLMessage.INFORM)
        answer.set_content("DONE")
        self.agent.send(answer)

class AgentParticipant(Agent):
    def __init__(self, aid, price=None, task_length=None, debug=False):
        super().__init__(aid, debug=debug)

        if price is None:
            self.price = lambda: 10 * random() + 100
        else:
            self.price = price

        self.behaviours.append(BehaviourParticipant(self))
