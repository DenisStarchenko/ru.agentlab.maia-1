/*******************************************************************************
 * Copyright (c) 2016 AgentLab.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package ru.agentlab.maia.container.impl;

import static com.google.common.base.Preconditions.checkNotNull;

import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.atomic.AtomicReference;

import ru.agentlab.maia.container.IContainer;
import ru.agentlab.maia.container.IInjector;

/**
 * <p>
 * Implementation guarantee that:
 * <ul>
 * <li>Context can have parent;</li>
 * <li>Context have unique UUID;</li>
 * <li>Context redirect service searching to parent if can't find it;</li>
 * <li>Context disable <code>null</code> keys for storing services;</li>
 * </ul>
 * 
 * @author Dmitriy Shishkin <shishkindimon@gmail.com>
 */
public class Container implements IContainer {

	protected final UUID uuid = UUID.randomUUID();

	protected final IInjector injector = new Injector(this);

	protected final AtomicReference<IContainer> parent = new AtomicReference<IContainer>(null);

	protected final Set<IContainer> childs = new ConcurrentSkipListSet<IContainer>();

	protected final Map<String, Object> map = new ConcurrentHashMap<String, Object>();

	{
		map.put(IContainer.class.getName(), this);
		map.put(Container.class.getName(), this);
		map.put(IInjector.class.getName(), injector);
		map.put(Injector.class.getName(), injector);
	}

	@Override
	public UUID getUuid() {
		return uuid;
	}

	@Override
	public IContainer getParent() {
		return parent.get();
	}

	@Override
	public IInjector getInjector() {
		return injector;
	}

	@Override
	public Object getLocal(String key) {
		checkNotNull(key);
		Object result = map.get(key);
		return result;
	}

	@Override
	public Object put(String key, Object value) {
		checkNotNull(key);
		return map.put(key, value);
	}

	@Override
	public Object remove(String key) {
		check(key);
		return map.remove(key);
	}

	@Override
	public IContainer setParent(IContainer container) {
		return parent.getAndSet(container);
	}

	@Override
	public Iterable<IContainer> getChilds() {
		return childs;
	}

	@Override
	public void addChild(IContainer container) {
		childs.add(container);
		container.setParent(this);
	}

	@Override
	public void removeChild(IContainer container) {
		childs.remove(container);
		container.setParent(null);
	}

	@Override
	public void clearChilds() {
		childs.forEach(container -> container.setParent(null));
		childs.clear();
	}

	@Override
	public Set<String> getKeySet() {
		return map.keySet();
	}

	@Override
	public Collection<Object> values() {
		return map.values();
	}

	@Override
	public boolean clear() {
		map.clear();
		return true;
	}
}