#ifdef _WIN32
#define _WIN32_DCOM
#endif
#include "smutex.h"

// SimpleMutex:: Constructors, Destructor, Asign operator.

SimpleMutex::SimpleMutex() noexcept
{
#ifdef _WIN32
	InitializeCriticalSectionAndSpinCount(&m_criticalSection, 0x80000020);
#else
	pthread_mutexattr_init(&m_criticalSectionAttr);
#ifndef __APPLE__
	pthread_mutexattr_settype(&m_criticalSectionAttr, PTHREAD_MUTEX_RECURSIVE_NP);
#endif
	pthread_mutex_init(&m_criticalSection, &m_criticalSectionAttr);
#endif
}

SimpleMutex::~SimpleMutex() noexcept
{
#ifdef _WIN32
	DeleteCriticalSection(&m_criticalSection);
#else
	pthread_mutexattr_destroy(&m_criticalSectionAttr);
	pthread_mutex_destroy(&m_criticalSection);
#endif
}

// ManualThreadLock:: Interaction.

void ManualThreadLock::doLock() noexcept
{
	m_mutex->lock();
	m_locked = true;
}

bool ManualThreadLock::doTryLock() noexcept
{
	if (m_mutex->tryLock() == false)
		return false;

	m_locked = true;
	return true;
}

void ManualThreadLock::doUnlock() noexcept
{
	m_locked = false;
	m_mutex->unlock();
}
