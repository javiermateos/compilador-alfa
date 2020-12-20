#ifndef __TABLAHASH_H_
#define __TABLAHASH_H_

#include "simbolo.h"
#include "tipos.h"

#define HASH_INI 5381
#define HASH_FACTOR 33

typedef struct s_Ht_item Ht_item;
typedef struct s_HashTable HashTable;
typedef struct s_LinkedList LinkedList;

LinkedList* get_LinkedList_next(LinkedList *list);
Ht_item* get_LinkedList_item(LinkedList* list);
HashTable *ht_create(int size);
void ht_free(HashTable *table);
simbolo* get_Htitem_value(Ht_item *ht);
Ht_item* ht_search(HashTable *table, const char *key);
STATUS ht_insert(HashTable *table, const char *key, simbolo *value);
void ht_delete(HashTable *table, const char *key);
LinkedList* get_Htitems(HashTable *table);

#endif
