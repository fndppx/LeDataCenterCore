#ifndef _CQuence_H
#define _CQuence_H

#ifdef	_WIN32
#include <windows.h>
#else
#include <pthread.h>
#endif

#include "CriticalSection.h"

struct STURCT_NODE
{
    void* m_pData;
    STURCT_NODE * m_pNext;
};



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
#pragma mark -
template <class T>
class CQuence
{
public:
    inline CQuence()
    {
        m_nNodeCount = 0;
        m_pHead = NULL;
        m_pTail = NULL;

		m_pCacheList = NULL;
		m_nCacheCount = 0;
		m_nMaxCacheSize = 5;
    }
    
    inline virtual ~CQuence()
	{
        STURCT_NODE * lpNode=NULL;
        while (m_pHead != NULL)
        {
            lpNode = m_pHead->m_pNext;
            delete (T*)m_pHead->m_pData;
            delete m_pHead;
            m_pHead =lpNode;
        }
		m_nNodeCount = 0;

		while (m_pCacheList != NULL)
		{
			lpNode = m_pCacheList->m_pNext;
            delete (T*)m_pCacheList->m_pData;
			delete m_pCacheList;
			m_pCacheList = lpNode;
		}
		m_nCacheCount = 0;        
    }

    inline int AddTail(T * apValue)
	{
        STURCT_NODE * lpNode= MallocNode();
        lpNode->m_pNext = NULL;
        lpNode->m_pData = apValue;
        if (m_pTail == NULL)
        {//√ª”– ˝æ›
            m_pHead = lpNode;
            m_pTail = lpNode;
        }
        else
        {
            m_pTail->m_pNext =lpNode;
            m_pTail = lpNode;
        }
        m_nNodeCount++;
        return m_nNodeCount;
    }

    inline T * GetHead()
    {
        if (m_pHead == NULL)
            return NULL;
        return (T*)m_pHead->m_pData;
    }

    inline T * DelHead()
    {
        if (m_pHead == NULL)
		{
            return NULL;
		}
        else
        {
            T *lpStru = (T*)m_pHead->m_pData;
            
			STURCT_NODE * lpNode = m_pHead->m_pNext;
            m_pHead->m_pData = NULL;
            FreeNode(m_pHead);
            m_pHead = lpNode;

            if (m_pHead == NULL)
                m_pTail= NULL;

            m_nNodeCount--;
            return lpStru;
        }
    };
    
    inline void ClearAll()
	{
        STURCT_NODE * lpNode=NULL;
        while (m_pHead != NULL)
        {
            lpNode = m_pHead->m_pNext;
            delete (T*)m_pHead->m_pData;
            m_pHead->m_pData = NULL;
            FreeNode(m_pHead);
            m_pHead = lpNode;
			if (m_pHead == NULL){
                m_pTail= NULL;
			}
        }
        m_nNodeCount = 0;
    }
    inline int GetCount(){return m_nNodeCount;};

	inline void SetCacheSize(int nCacheSize)
	{
		m_nMaxCacheSize = nCacheSize;
	}

	inline STURCT_NODE *MallocNode()
	{
		if (m_pCacheList != NULL)
		{
			STURCT_NODE * lpNode = m_pCacheList;
			m_pCacheList = m_pCacheList->m_pNext;

			m_nCacheCount--;
			return lpNode;
		}
		else
		{
			return new STURCT_NODE();
		}
	}

	inline void FreeNode(STURCT_NODE *&pNode)
	{
//		ASSERT(pNode != NULL);

		if (m_nCacheCount < m_nMaxCacheSize)
		{
			pNode->m_pNext = m_pCacheList;
			m_pCacheList = pNode;
			m_nCacheCount++;
		}
		else
		{
			delete pNode;
		}
		pNode = NULL;
	}
private:
    int m_nNodeCount;
    STURCT_NODE *m_pHead;
    STURCT_NODE *m_pTail;
	STURCT_NODE *m_pCacheList;
	int m_nCacheCount;
	int m_nMaxCacheSize;
};



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
#pragma mark -
template <class T>
class CSafeQuence
{
public:
    inline CSafeQuence()
    {
        m_nNodeCount = 0;
        m_pHead = NULL;
        m_pTail = NULL;

		m_pCacheList = NULL;
		m_nCacheCount = 0;
		m_nMaxCacheSize = 5;
    }
    
    inline ~CSafeQuence()
	{
        m_oLock.Lock();
        STURCT_NODE * lpNode=NULL;
        while (m_pHead != NULL)
        {
            lpNode = m_pHead->m_pNext;
            delete (T*)m_pHead->m_pData;
            delete m_pHead;
            m_pHead =lpNode;
        }
        m_nNodeCount = 0;
        m_oLock.UnLock();

        m_oCacheLock.Lock();
		while (m_pCacheList != NULL)
		{
			lpNode = m_pCacheList->m_pNext;
			delete (T*)m_pCacheList->m_pData;
			delete m_pCacheList;
			m_pCacheList = lpNode;
		}
		m_nCacheCount = 0;
        m_oCacheLock.UnLock();
    };

    inline int AddTail(T * apValue)
	{
        m_oLock.Lock();

		STURCT_NODE * lpNode= MallocNode();
        lpNode->m_pNext = NULL;
        lpNode->m_pData = apValue;

        if (m_pTail == NULL)
        {//√ª”– ˝æ›
            m_pHead = lpNode;
            m_pTail = lpNode;
        }
        else
        {
            m_pTail->m_pNext =lpNode;
            m_pTail = lpNode;
        }
        m_nNodeCount++;
        int nNodeCount = m_nNodeCount;

        m_oLock.UnLock();
        return nNodeCount;
    };
    inline T * DelHead()
    {
        T* lstru = NULL;

        m_oLock.Lock();
        
        if (m_pHead == NULL)
		{
            lstru = NULL;
		}
        else
        {
            lstru = (T*)m_pHead->m_pData;
            m_pHead->m_pData = NULL;
            
			STURCT_NODE * lpNode = m_pHead->m_pNext;
            FreeNode(m_pHead);
            m_pHead = lpNode;
            if (m_pHead == NULL)
                m_pTail= NULL;
            m_nNodeCount--;
        }
        
        m_oLock.UnLock();
        
        return lstru;
    };
    
    inline T * GetHead()
    {
        T* lstru;

        m_oLock.Lock();
        
        if (m_pHead == NULL)
            lstru = NULL;
        else
            lstru = (T*)m_pHead->m_pData;

        m_oLock.UnLock();
        return lstru;
    };


    inline void ClearAll()
	{
        STURCT_NODE * lpNode=NULL;
        
        m_oLock.Lock();
        
        while (m_pHead != NULL)
        {
            lpNode = m_pHead->m_pNext;
            delete (T*)m_pHead->m_pData;
            FreeNode(m_pHead);
            m_pHead =lpNode;
            if (m_pHead == NULL)
                m_pTail= NULL;
        }
        m_nNodeCount = 0;
        
        m_oLock.UnLock();
    }

    inline int GetCount(){return m_nNodeCount;};

	inline void SetCacheSize(int nCacheSize)
	{
		m_nMaxCacheSize = nCacheSize;
	}

	inline STURCT_NODE *MallocNode()
	{
        STURCT_NODE * lpNode = NULL;
        
        m_oCacheLock.Lock();
        
		if (m_pCacheList != NULL)
		{
			lpNode = m_pCacheList;
			m_pCacheList = m_pCacheList->m_pNext;

			m_nCacheCount--;
		}
        
        m_oCacheLock.UnLock();
        
        if(lpNode == NULL)
        {
            lpNode = new STURCT_NODE();
        }

        return lpNode;
	}

	inline void FreeNode(STURCT_NODE *&pNode)
	{
//		ASSERT(pNode != NULL);
        
        pNode->m_pData= NULL;
        
        m_oCacheLock.Lock();

		if (m_nCacheCount < m_nMaxCacheSize)
		{
			pNode->m_pNext = m_pCacheList;
			m_pCacheList = pNode;
			m_nCacheCount++;
            
            pNode = NULL;
		}
        
        m_oCacheLock.UnLock();
		
        if(pNode != NULL)
        {
			delete pNode;
            pNode = NULL;
		}
	}
    
private:
    int m_nNodeCount;

    CCriticalSection m_oLock;
    CCriticalSection m_oCacheLock;
    STURCT_NODE *m_pHead;
    STURCT_NODE *m_pTail;

	STURCT_NODE *m_pCacheList;
	int m_nCacheCount;
	int m_nMaxCacheSize;
};
#endif //_CQuence_H

