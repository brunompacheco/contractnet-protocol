from random import random

from pade.misc.utility import call_later, display_message
from pade.core.agent import Agent
from pade.acl.aid import AID
from pade.acl.messages import ACLMessage
from pade.behaviours.protocols import FipaContractNetProtocol

class BehaviourParticipant(FipaContractNetProtocol):
    def __init__(self, agent, message=None):
        super().__init__(agent, message=message, is_initiator=False)

        self.available = True

    def display(self, msg: str):
        return display_message(self.agent.aid.name, msg)

    def handle_cfp(self, message):
        super().handle_cfp(message)

        disp = f"Call for proposals received for contract '{message.content}', "
        if self.available:
            disp += "I'm available!"

            answer = message.create_reply()
            answer.set_performative(ACLMessage.PROPOSE)
            answer.set_content(self.agent.price)
            self.agent.send(answer)
        else:
            disp += "but I'm not available"

            answer = message.create_reply()
            answer.set_performative(ACLMessage.REFUSE)
            self.agent.send(answer)

        self.display(disp)

    def handle_reject_propose(self, message):
        super().handle_reject_propose(message)

        self.display(f"Proposal rejected for contract '{message.content}'")

    def handle_accept_propose(self, message):
        super().handle_accept_propose(message)

        self.display(f"Proposal accepted for contract '{message.content}'")

        self.do_task(message)

    def do_task(self, message):
        if self.available:
            self.available = False
            call_later(self.agent.task_length, self.inform_done, message)
        else:
            call_later(0.1, self.do_task, message)

    def inform_done(self, message):
        self.display(f"Finished contract '{message.content}'")

        answer = message.create_reply()
        answer.set_performative(ACLMessage.INFORM)
        answer.set_content("DONE")
        self.agent.send(answer)

        self.available = True

class AgentParticipant(Agent):
    def __init__(self, aid, price=None, task_length=None, debug=False):
        super().__init__(aid, debug=debug)

        if price is None:
            self.price = 10 * random() + 100
        else:
            self.price = price
        
        if task_length is None:
            self.task_length = 0.5 + random() * 0.5
        else:
            self.task_length = task_length

        self.behaviours.append(BehaviourParticipant(self))
