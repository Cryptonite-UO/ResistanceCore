/**
* @file CResourceLink.cpp
*
*/

#include "../../game/chars/CChar.h"
#include "../../game/items/CItem.h"
#include "../../game/triggers.h"
#include "blocks/CSkillDef.h"
#include "blocks/CSpellDef.h"
#include "blocks/CRegionResourceDef.h"
#include "blocks/CWebPageDef.h"
#include "CResourceLock.h"
#include "CResourceLink.h"


CResourceLink::CResourceLink( CResourceID rid, const CVarDefContNum * pDef ) :
    CResourceDef( rid, pDef )
{
    m_pScript = nullptr;
    m_Context.Init(); // not yet tested.
    m_lRefInstances = 0;
    ClearTriggers();
}

void CResourceLink::ScanSection( RES_TYPE restype )
{
    ADDTOCALLSTACK("CResourceLink::ScanSection");
    // Scan the section we are linking to for useful stuff.
    ASSERT(m_pScript);
    lpctstr const * ppTable = nullptr;
    int iQty = 0;

    switch (restype)
    {
        case RES_TYPEDEF:
        case RES_ITEMDEF:
            ppTable = CItem::sm_szTrigName;
            iQty = ITRIG_QTY;
            break;
        case RES_CHARDEF:
        case RES_EVENTS:
        case RES_SKILLCLASS:
            ppTable = CChar::sm_szTrigName;
            iQty = CTRIG_QTY;
            break;
        case RES_SKILL:
            ppTable = CSkillDef::sm_szTrigName;
            iQty = SKTRIG_QTY;
            break;
        case RES_SPELL:
            ppTable = CSpellDef::sm_szTrigName;
            iQty = SPTRIG_QTY;
            break;
        case RES_AREA:
        case RES_ROOM:
        case RES_REGIONTYPE:
            ppTable = CRegionWorld::sm_szTrigName;
            iQty = RTRIG_QTY;
            break;
        case RES_WEBPAGE:
            ppTable = CWebPageDef::sm_szTrigName;
            iQty = WTRIG_QTY;
            break;
        case RES_REGIONRESOURCE:
            ppTable = CRegionResourceDef::sm_szTrigName;
            iQty = RRTRIG_QTY;
            break;
        default:
            break;
    }
    ClearTriggers();

    while ( m_pScript->ReadKey(false) )
    {
        if ( m_pScript->IsKeyHead( "DEFNAME", 7 ) )
        {
            m_pScript->ParseKeyLate();
            SetResourceName( m_pScript->GetArgRaw() );
        }
        else if ( m_pScript->IsKeyHead( "ON", 2 ) )
        {
            int iTrigger;
            if ( iQty )
            {
                m_pScript->ParseKeyLate();
                iTrigger = FindTableSorted( m_pScript->GetArgRaw(), ppTable, iQty );

                if ( iTrigger < 0 )	// unknown triggers ?
                    iTrigger = XTRIG_UNKNOWN;
                else
                {
                    TriglistAdd(m_pScript->GetArgRaw());
                    if ( HasTrigger(iTrigger) )
                    {
                        DEBUG_ERR(( "Duplicate trigger '%s' in '%s'\n", ppTable[iTrigger], GetResourceName() ));
                        continue;
                    }
                }
            }
            else
                iTrigger = XTRIG_UNKNOWN;

            SetTrigger(iTrigger);
        }
    }
}


bool CResourceLink::IsLinked() const
{
    ADDTOCALLSTACK("CResourceLink::IsLinked");
    if ( !m_pScript )
        return false;
    return m_Context.IsValid();
}

CResourceScript *CResourceLink::GetLinkFile() const
{
    ADDTOCALLSTACK("CResourceLink::GetLinkFile");
    return m_pScript;
}

int CResourceLink::GetLinkOffset() const
{
    ADDTOCALLSTACK("CResourceLink::GetLinkOffset");
    return m_Context.m_iOffset;
}

void CResourceLink::SetLink(CResourceScript *pScript)
{
    ADDTOCALLSTACK("CResourceLink::SetLink");
    m_pScript = pScript;
    m_Context = pScript->GetContext();
}

void CResourceLink::CopyTransfer(CResourceLink *pLink)
{
    ADDTOCALLSTACK("CResourceLink::CopyTransfer");
    ASSERT(pLink);
    CResourceDef::CopyDef( pLink );
    m_pScript = pLink->m_pScript;
    m_Context = pLink->m_Context;
    memcpy(m_dwOnTriggers, pLink->m_dwOnTriggers, sizeof(m_dwOnTriggers));
    m_lRefInstances = pLink->m_lRefInstances;
    pLink->m_lRefInstances = 0;	// instance has been transfered.
}

void CResourceLink::ClearTriggers()
{
    ADDTOCALLSTACK("CResourceLink::ClearTriggers");
    memset(m_dwOnTriggers, 0, sizeof(m_dwOnTriggers));
}

void CResourceLink::SetTrigger(int i)
{
    ADDTOCALLSTACK("CResourceLink::SetTrigger");
    if ( i >= 0 )
    {
        for ( int j = 0; j < MAX_TRIGGERS_ARRAY; ++j )
        {
            if ( i < 32 )
            {
                dword flag = 1 << i;
                m_dwOnTriggers[j] |= flag;
                return;
            }
            i -= 32;
        }
    }
}

bool CResourceLink::HasTrigger(int i) const
{
    ADDTOCALLSTACK("CResourceLink::HasTrigger");
    // Specific to the RES_TYPE; CTRIG_QTY, ITRIG_QTY or RTRIG_QTY
    if ( i < XTRIG_UNKNOWN )
        i = XTRIG_UNKNOWN;

    for ( int j = 0; j < MAX_TRIGGERS_ARRAY; ++j )
    {
        if ( i < 32 )
        {
            dword flag = 1 << i;
            return ((m_dwOnTriggers[j] & flag) != 0);
        }
        i -= 32;
    }
    return false;
}

bool CResourceLink::ResourceLock( CResourceLock &s )
{
    ADDTOCALLSTACK("CResourceLink::ResourceLock");
    // Find the definition of this item in the scripts.
    // Open a locked copy of this script
    // NOTE: How can we tell the file has changed since last open ?
    // RETURN: true = found it.
    if ( !IsLinked() )	// has already failed previously.
        return false;

    ASSERT(m_pScript);

    //	Give several tryes to lock the script while multithreading
    int iRet = s.OpenLock( m_pScript, m_Context );
    if ( ! iRet )
        return true;

    s.AttachObj( this );

    // ret = -2 or -3
    lpctstr pszName = GetResourceName();
    DEBUG_ERR(("ResourceLock '%s':%d id=%s FAILED\n", s.GetFilePath(), m_Context.m_iOffset, pszName));

    return false;
}