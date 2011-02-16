/*
 *	server/zone/objects/tangible/InstrumentObserver.cpp generated by engine3 IDL compiler 0.60
 */

#include "InstrumentObserver.h"

#include "server/zone/objects/creature/CreatureObject.h"

#include "server/zone/objects/tangible/Instrument.h"

/*
 *	InstrumentObserverStub
 */

InstrumentObserver::InstrumentObserver(Instrument* instr) : Observer(DummyConstructorParameter::instance()) {
	InstrumentObserverImplementation* _implementation = new InstrumentObserverImplementation(instr);
	_impl = _implementation;
	_impl->_setStub(this);
}

InstrumentObserver::InstrumentObserver(DummyConstructorParameter* param) : Observer(param) {
}

InstrumentObserver::~InstrumentObserver() {
}


int InstrumentObserver::notifyObserverEvent(unsigned int eventType, Observable* observable, ManagedObject* arg1, long long arg2) {
	InstrumentObserverImplementation* _implementation = (InstrumentObserverImplementation*) _getImplementation();
	if (_implementation == NULL) {
		if (!deployed)
			throw ObjectNotDeployedException(this);

		DistributedMethod method(this, 6);
		method.addUnsignedIntParameter(eventType);
		method.addObjectParameter(observable);
		method.addObjectParameter(arg1);
		method.addSignedLongParameter(arg2);

		return method.executeWithSignedIntReturn();
	} else
		return _implementation->notifyObserverEvent(eventType, observable, arg1, arg2);
}

DistributedObjectServant* InstrumentObserver::_getImplementation() {

	_updated = true;
	return _impl;
}

void InstrumentObserver::_setImplementation(DistributedObjectServant* servant) {
	_impl = servant;
}

/*
 *	InstrumentObserverImplementation
 */

InstrumentObserverImplementation::InstrumentObserverImplementation(DummyConstructorParameter* param) : ObserverImplementation(param) {
	_initializeImplementation();
}


InstrumentObserverImplementation::~InstrumentObserverImplementation() {
}


void InstrumentObserverImplementation::finalize() {
}

void InstrumentObserverImplementation::_initializeImplementation() {
	_setClassHelper(InstrumentObserverHelper::instance());

	_serializationHelperMethod();
	_serializationHelperMethod();
}

void InstrumentObserverImplementation::_setStub(DistributedObjectStub* stub) {
	_this = (InstrumentObserver*) stub;
	ObserverImplementation::_setStub(stub);
}

DistributedObjectStub* InstrumentObserverImplementation::_getStub() {
	return _this;
}

InstrumentObserverImplementation::operator const InstrumentObserver*() {
	return _this;
}

void InstrumentObserverImplementation::lock(bool doLock) {
	_this->lock(doLock);
}

void InstrumentObserverImplementation::lock(ManagedObject* obj) {
	_this->lock(obj);
}

void InstrumentObserverImplementation::rlock(bool doLock) {
	_this->rlock(doLock);
}

void InstrumentObserverImplementation::wlock(bool doLock) {
	_this->wlock(doLock);
}

void InstrumentObserverImplementation::wlock(ManagedObject* obj) {
	_this->wlock(obj);
}

void InstrumentObserverImplementation::unlock(bool doLock) {
	_this->unlock(doLock);
}

void InstrumentObserverImplementation::runlock(bool doLock) {
	_this->runlock(doLock);
}

void InstrumentObserverImplementation::_serializationHelperMethod() {
	ObserverImplementation::_serializationHelperMethod();

	_setClassName("InstrumentObserver");

}

void InstrumentObserverImplementation::readObject(ObjectInputStream* stream) {
	uint16 _varCount = stream->readShort();
	for (int i = 0; i < _varCount; ++i) {
		String _name;
		_name.parseFromBinaryStream(stream);

		uint16 _varSize = stream->readShort();

		int _currentOffset = stream->getOffset();

		if(InstrumentObserverImplementation::readObjectMember(stream, _name)) {
		}

		stream->setOffset(_currentOffset + _varSize);
	}

	initializeTransientMembers();
}

bool InstrumentObserverImplementation::readObjectMember(ObjectInputStream* stream, const String& _name) {
	if (ObserverImplementation::readObjectMember(stream, _name))
		return true;

	if (_name == "instrument") {
		TypeInfo<ManagedWeakReference<Instrument* > >::parseFromBinaryStream(&instrument, stream);
		return true;
	}


	return false;
}

void InstrumentObserverImplementation::writeObject(ObjectOutputStream* stream) {
	int _currentOffset = stream->getOffset();
	stream->writeShort(0);
	int _varCount = InstrumentObserverImplementation::writeObjectMembers(stream);
	stream->writeShort(_currentOffset, _varCount);
}

int InstrumentObserverImplementation::writeObjectMembers(ObjectOutputStream* stream) {
	String _name;
	int _offset;
	uint16 _totalSize;
	_name = "instrument";
	_name.toBinaryStream(stream);
	_offset = stream->getOffset();
	stream->writeShort(0);
	TypeInfo<ManagedWeakReference<Instrument* > >::toBinaryStream(&instrument, stream);
	_totalSize = (uint16) (stream->getOffset() - (_offset + 2));
	stream->writeShort(_offset, _totalSize);


	return 1 + ObserverImplementation::writeObjectMembers(stream);
}

InstrumentObserverImplementation::InstrumentObserverImplementation(Instrument* instr) {
	_initializeImplementation();
	// server/zone/objects/tangible/InstrumentObserver.idl(65):  		instrument = instr;
	instrument = instr;
}

/*
 *	InstrumentObserverAdapter
 */

InstrumentObserverAdapter::InstrumentObserverAdapter(InstrumentObserverImplementation* obj) : ObserverAdapter(obj) {
}

Packet* InstrumentObserverAdapter::invokeMethod(uint32 methid, DistributedMethod* inv) {
	Packet* resp = new MethodReturnMessage(0);

	switch (methid) {
	case 6:
		resp->insertSignedInt(notifyObserverEvent(inv->getUnsignedIntParameter(), (Observable*) inv->getObjectParameter(), (ManagedObject*) inv->getObjectParameter(), inv->getSignedLongParameter()));
		break;
	default:
		return NULL;
	}

	return resp;
}

int InstrumentObserverAdapter::notifyObserverEvent(unsigned int eventType, Observable* observable, ManagedObject* arg1, long long arg2) {
	return ((InstrumentObserverImplementation*) impl)->notifyObserverEvent(eventType, observable, arg1, arg2);
}

/*
 *	InstrumentObserverHelper
 */

InstrumentObserverHelper* InstrumentObserverHelper::staticInitializer = InstrumentObserverHelper::instance();

InstrumentObserverHelper::InstrumentObserverHelper() {
	className = "InstrumentObserver";

	Core::getObjectBroker()->registerClass(className, this);
}

void InstrumentObserverHelper::finalizeHelper() {
	InstrumentObserverHelper::finalize();
}

DistributedObject* InstrumentObserverHelper::instantiateObject() {
	return new InstrumentObserver(DummyConstructorParameter::instance());
}

DistributedObjectServant* InstrumentObserverHelper::instantiateServant() {
	return new InstrumentObserverImplementation(DummyConstructorParameter::instance());
}

DistributedObjectAdapter* InstrumentObserverHelper::createAdapter(DistributedObjectStub* obj) {
	DistributedObjectAdapter* adapter = new InstrumentObserverAdapter((InstrumentObserverImplementation*) obj->_getImplementation());

	obj->_setClassName(className);
	obj->_setClassHelper(this);

	adapter->setStub(obj);

	return adapter;
}

