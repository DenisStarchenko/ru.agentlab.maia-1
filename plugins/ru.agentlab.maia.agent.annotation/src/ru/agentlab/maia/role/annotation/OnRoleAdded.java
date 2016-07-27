package ru.agentlab.maia.role.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import ru.agentlab.maia.agent.event.RoleAddedEvent;
import ru.agentlab.maia.annotation.PlanEventFilter;
import ru.agentlab.maia.role.annotation.converter.OnRoleXXXConverter;

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@PlanEventFilter(converter = OnRoleXXXConverter.class, eventType = RoleAddedEvent.class)
public @interface OnRoleAdded {

	Class<?> value();

}
