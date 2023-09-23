#pragma once
#include <unordered_set>
#include "tile.h"
#include "creature.h"

class ZoneData
{
public:
	std::unordered_set<Tile*> tiles;

	const std::vector<Position> getPositions() const
	{
		std::vector<Position> positions;
		for (auto& itTile : tiles)
		{
			positions.push_back(itTile->getPosition());
		}

		return positions;
	}

	void addTile(Tile* tile) {
		tiles.insert(tile);
	}

	size_t getCreatureCount(CreatureType_t dataType)	const { return getCount(dataType); }
	size_t getCreatureCount()							const { return getCount(CREATURETYPE_ANY); }
	size_t getPlayerCount()								const { return getCount(CREATURETYPE_PLAYER); }
	size_t getNpcCount()								const { return getCount(CREATURETYPE_NPC); }
	size_t getMonsterCount()							const { return getCount(CREATURETYPE_MONSTER); }
	size_t getTilesCount()								const { return tiles.size(); }

	const CreatureVector getCreatures(CreatureType_t dataType)		const { return getCreaturesByType(dataType); }
	const CreatureVector getCreatures()								const { return getCreaturesByType(CREATURETYPE_ANY); }
	const CreatureVector getPlayers()								const { return getCreaturesByType(CREATURETYPE_PLAYER); }
	const CreatureVector getNpcs()									const { return getCreaturesByType(CREATURETYPE_NPC); }
	const CreatureVector getMonsters()								const { return getCreaturesByType(CREATURETYPE_MONSTER); }

	std::vector<Tile*> getTiles() const {
		std::vector<Tile*> tileVector;
		for (auto tile : tiles) {
			tileVector.push_back(tile);
		}
		return tileVector;
	}
	//New constructor
	ZoneData(Tile* tile) {
		tiles.insert(tile);
	}
private:
	inline bool checkCreature(CreatureType_t dataType, Creature* creature) const
	{
		return (dataType == CREATURETYPE_PLAYER && creature->getPlayer()) ||
			(dataType == CREATURETYPE_NPC && creature->getNpc()) ||
			(dataType == CREATURETYPE_MONSTER && creature->getMonster());
	}

	size_t getCount(CreatureType_t dataType) const
	{
		size_t count = 0;
		for (auto& itTile : tiles)
		{
			CreatureVector* tileCreatures = itTile->getCreatures();
			if (!tileCreatures)
			{
				continue;
			}

			switch (dataType)
			{
			case CREATURETYPE_ANY:
			{
				count += tileCreatures->size();
				break;
			}
			case CREATURETYPE_PLAYER:
			case CREATURETYPE_NPC:
			case CREATURETYPE_MONSTER:
			{
				for (auto& itCreature : *tileCreatures)
				{
					if (checkCreature(dataType, itCreature))
					{
						count++;
					}
				}

				break;
			}
			default:
				break;
			}
		}

		return count;
	}

	CreatureVector getCreaturesByType(CreatureType_t dataType) const
	{
		CreatureVector creatures;
		for (auto& itTile : tiles)
		{
			CreatureVector* tileCreatures = itTile->getCreatures();
			if (!tileCreatures)
			{
				continue;
			}

			switch (dataType)
			{
			case CREATURETYPE_ANY:
			{
				creatures.insert(creatures.end(), tileCreatures->begin(), tileCreatures->end());
				break;
			}
			case CREATURETYPE_PLAYER:
			case CREATURETYPE_NPC:
			case CREATURETYPE_MONSTER:
			{
				for (auto& itCreature : *tileCreatures)
				{
					if (checkCreature(dataType, itCreature))
					{
						creatures.push_back(itCreature);
					}
				}

				break;
			}
			default:
				break;
			}
		}

		return creatures;
	}


};
