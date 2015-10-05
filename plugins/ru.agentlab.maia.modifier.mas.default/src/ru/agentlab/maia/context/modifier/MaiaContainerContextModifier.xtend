package ru.agentlab.maia.context.modifier

import javax.annotation.PostConstruct
import javax.inject.Inject
import ru.agentlab.maia.execution.ExecutionService
import ru.agentlab.maia.execution.IExecutionNode
import ru.agentlab.maia.memory.IMaiaContext
import ru.agentlab.maia.memory.IMaiaContextInjector
import ru.agentlab.maia.execution.scheduler.sequential.SequentialTaskScheduler
import ru.agentlab.maia.execution.ITaskExecutor

class MaiaContainerContextModifier {

	@Inject
	IMaiaContext context

	@PostConstruct
	def void setup() {
		context => [
			putService(IMaiaContext.KEY_TYPE, "container")
			getService(IMaiaContextInjector) => [
				deploy(SequentialTaskScheduler, IExecutionNode)
				deploy(ExecutionService, ITaskExecutor)
			]
		]
	}
}