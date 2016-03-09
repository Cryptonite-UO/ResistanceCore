#ifndef _INC_CCHATCHANMEMBER_H
#define _INC_CCHATCHANMEMBER_H

#include <grayproto.h>
#include "../common/CArray.h"
#include "../common/CString.h"

class CClient;

class CChatChanMember
{
    // This is a member of the CClient.
private:
    bool m_fChatActive;
    bool m_fReceiving;
    bool m_fAllowWhoIs;
    CChatChannel * m_pChannel;	// I can only be a member of one chan at a time.
public:
    static const char *m_sClassName;
    CGObArray< CGString * > m_IgnoredMembers;	// Player's list of ignored members
private:
    friend class CChatChannel;
    friend class CChat;
    // friend CClient;
    bool GetWhoIs() const { return m_fAllowWhoIs; }
    void SetWhoIs(bool fAllowWhoIs) { m_fAllowWhoIs = fAllowWhoIs; }
    bool IsReceivingAllowed() const { return m_fReceiving; }
    LPCTSTR GetChatName() const;

    size_t FindIgnoringIndex( LPCTSTR pszName) const;

protected:
    void SetChatActive();
    void SetChatInactive();
public:
    CChatChanMember();
    virtual ~CChatChanMember();

private:
    CChatChanMember(const CChatChanMember& copy);
    CChatChanMember& operator=(const CChatChanMember& other);

public:
    CClient * GetClient();
    const CClient * GetClient() const;
    bool IsChatActive() const;
    void SetReceiving(bool fOnOff);
    void ToggleReceiving();

    void PermitWhoIs();
    void ForbidWhoIs();
    void ToggleWhoIs();

    CChatChannel * GetChannel() const { return m_pChannel; }
    void SetChannel(CChatChannel * pChannel) { m_pChannel = pChannel; }
    void SendChatMsg( CHATMSG_TYPE iType, LPCTSTR pszName1 = NULL, LPCTSTR pszName2 = NULL, CLanguageID lang = 0 );
    void RenameChannel(LPCTSTR pszName);

    void Ignore(LPCTSTR pszName);
    void DontIgnore(LPCTSTR pszName);
    void ToggleIgnore(LPCTSTR pszName);
    void ClearIgnoreList();
    bool IsIgnoring(LPCTSTR pszName) const;
};

#endif //_INC_CCHATCHANMEMBER_H

