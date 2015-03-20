/** 
 * JADE - Java IAgent DEvelopment Framework is a framework to develop 
 * multi-agent systems in compliance with the FIPA specifications.
 * Copyright (C) 2000 CSELT S.p.A. 
 * GNU Lesser General Public License
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, 
 * version 2.1 of the License. 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA  02111-1307, USA.
 */
package ru.agentlab.maia.messageq.internal

import java.util.Iterator
import java.util.LinkedList
import java.util.List
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import ru.agentlab.maia.IAgent
import ru.agentlab.maia.IMessageTemplate
import ru.agentlab.maia.messageq.IMessageQueue
import ru.agentlab.maia.IMessage

/** 
 * @author Giovanni Rimassa - Universita` di Parma
 * @version $Date: 2006-01-12 13:21:47 +0100 (gio, 12 gen 2006) $ $Revision:
 * 5847 $
 */
class MessageQueue implements IMessageQueue {
	LinkedList list
	int maxSize
	IAgent agent
	static Logger logger = LoggerFactory.getLogger(MessageQueue.getName())

	new(int size, IAgent a) {
		maxSize = size
		agent = a
		list = new LinkedList()
	}

	new() {
		this(0, null)
	}

	override boolean isEmpty() {
		return list.isEmpty()
	}

	override void setMaxSize(int newSize) throws IllegalArgumentException {
		if(newSize < 0) throw new IllegalArgumentException("Invalid MsgQueue size")
		maxSize = newSize
	}

	override int getMaxSize() {
		return maxSize
	}

	/** 
	 * @return the number of messages currently in the queue
	 */
	override int size() {
		return list.size()
	}

	override void addFirst(IMessage msg) {
		if ((maxSize != 0) && (list.size() >= maxSize)) {
			list.removeFirst() // FIFO replacement policy
		}
		list.addFirst(msg)
	}

	override void addLast(IMessage msg) {
		if ((maxSize != 0) && (list.size() >= maxSize)) {
			list.removeFirst() // FIFO replacement policy
			logger.error("IAgent {} - Message queue size exceeded. Message discarded!!!!!", getIAgentName())
		}
		list.addLast(msg)
	}

	def private String getIAgentName() {
		return if(agent != null) agent.getLocalName() else "null"
	}

	override IMessage receive(IMessageTemplate pattern) {
		var IMessage result = null
		// This is just for the MIDP implementation where iterator.remove() is
		// not supported.
		// We don't surround it with preprocessor directives to avoid making the
		// code unreadable
		var int cnt = 0

		for (var Iterator messages = iterator(); messages.hasNext(); cnt++) {
			var IMessage msg = messages.next() as IMessage
			if (pattern == null || pattern.match(msg)) {
				messages.remove()
				result = msg /* FIXME Unsupported BreakStatement: */
			}

		}
		return result
	}

	def private Iterator iterator() {
		return list.iterator()
	}

	// For persistence service
	def private void setMessages(List l) {
		// FIXME: To be implemented
		System.out.println(">>> MessageQueue::setMessages() <<<")
	}

	// For persistence service
	def private List getMessages() {
		// FIXME: To be implemented
		System.out.println(">>> MessageQueue::getMessages() <<<")
		return null
	}

	// #J2ME_EXCLUDE_END
	// For persistence service
	Long persistentID

	// For persistence service
	def private Long getPersistentID() {
		return persistentID
	}

	// For persistence service
	def private void setPersistentID(Long l) {
		persistentID = l
	}

	override void copyTo(List messages) {

		for (var Iterator i = iterator(); i.hasNext(); messages.add(i.next()));
	}

	// For debugging purpose
	def package Object[] getAllMessages() {
		return list.toArray()
	}

	def package void cleanOldMessages(long maxTime, IMessageTemplate pattern) {
		var long now = System.currentTimeMillis()
		var int cnt = 0

		for (var Iterator messages = iterator(); messages.hasNext(); cnt++) {
			var IMessage msg = messages.next() as IMessage
			var long postTime = msg.getPostTimeStamp()
			if (postTime > 0 && ((now - postTime) > maxTime)) {
				if (pattern == null || pattern.match(msg)) {
					messages.remove()
				}

			}

		}

	}

}