/*
 *	server/zone/objects/player/sui/listbox/teachplayerlistbox/TeachPlayerListBox.h generated by engine3 IDL compiler 0.60
 */

#ifndef TEACHPLAYERLISTBOX_H_
#define TEACHPLAYERLISTBOX_H_

#include "engine/core/Core.h"

#include "engine/core/ManagedReference.h"

#include "engine/core/ManagedWeakReference.h"

namespace server {
namespace zone {
namespace objects {
namespace creature {
namespace professions {

class SkillBox;

} // namespace professions
} // namespace creature
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::creature::professions;

namespace server {
namespace zone {
namespace objects {
namespace player {

class PlayerCreature;

} // namespace player
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::player;

#include "server/zone/objects/player/sui/listbox/SuiListBox.h"

namespace server {
namespace zone {
namespace objects {
namespace player {
namespace sui {
namespace listbox {

class TeachPlayerListBox : public SuiListBox {
public:
	TeachPlayerListBox(PlayerCreature* player);

	void setStudent(PlayerCreature* student);

	PlayerCreature* getStudent();

	const String getTeachingSkillOption(int index);

	bool generateSkillList(PlayerCreature* teacher, PlayerCreature* student);

	DistributedObjectServant* _getImplementation();

	void _setImplementation(DistributedObjectServant* servant);

protected:
	TeachPlayerListBox(DummyConstructorParameter* param);

	virtual ~TeachPlayerListBox();

	friend class TeachPlayerListBoxHelper;
};

} // namespace listbox
} // namespace sui
} // namespace player
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::player::sui::listbox;

namespace server {
namespace zone {
namespace objects {
namespace player {
namespace sui {
namespace listbox {

class TeachPlayerListBoxImplementation : public SuiListBoxImplementation {
	ManagedReference<PlayerCreature* > studentPlayer;

	Vector<SkillBox*> teachingSkillOptions;

public:
	TeachPlayerListBoxImplementation(PlayerCreature* player);

	TeachPlayerListBoxImplementation(DummyConstructorParameter* param);

private:
	void init();

public:
	void setStudent(PlayerCreature* student);

	PlayerCreature* getStudent();

	const String getTeachingSkillOption(int index);

	bool generateSkillList(PlayerCreature* teacher, PlayerCreature* student);

	TeachPlayerListBox* _this;

	operator const TeachPlayerListBox*();

	DistributedObjectStub* _getStub();
	virtual void readObject(ObjectInputStream* stream);
	virtual void writeObject(ObjectOutputStream* stream);
protected:
	virtual ~TeachPlayerListBoxImplementation();

	void finalize();

	void _initializeImplementation();

	void _setStub(DistributedObjectStub* stub);

	void lock(bool doLock = true);

	void lock(ManagedObject* obj);

	void rlock(bool doLock = true);

	void wlock(bool doLock = true);

	void wlock(ManagedObject* obj);

	void unlock(bool doLock = true);

	void runlock(bool doLock = true);

	void _serializationHelperMethod();
	bool readObjectMember(ObjectInputStream* stream, const String& name);
	int writeObjectMembers(ObjectOutputStream* stream);

	friend class TeachPlayerListBox;
};

class TeachPlayerListBoxAdapter : public SuiListBoxAdapter {
public:
	TeachPlayerListBoxAdapter(TeachPlayerListBoxImplementation* impl);

	Packet* invokeMethod(sys::uint32 methid, DistributedMethod* method);

	void setStudent(PlayerCreature* student);

	bool generateSkillList(PlayerCreature* teacher, PlayerCreature* student);

};

class TeachPlayerListBoxHelper : public DistributedObjectClassHelper, public Singleton<TeachPlayerListBoxHelper> {
	static TeachPlayerListBoxHelper* staticInitializer;

public:
	TeachPlayerListBoxHelper();

	void finalizeHelper();

	DistributedObject* instantiateObject();

	DistributedObjectServant* instantiateServant();

	DistributedObjectAdapter* createAdapter(DistributedObjectStub* obj);

	friend class Singleton<TeachPlayerListBoxHelper>;
};

} // namespace listbox
} // namespace sui
} // namespace player
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::player::sui::listbox;

#endif /*TEACHPLAYERLISTBOX_H_*/
