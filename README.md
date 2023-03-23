[![Build status](https://ci.appveyor.com/api/projects/status/q22icjwv5h5bonav/branch/master?svg=true)](https://ci.appveyor.com/project/Jhobean/cryptocore-f7p6q/branch/master) (Appveyor)

[![Build Status](https://travis-ci.com/Cryptonite-UO/CryptoCore.svg?branch=master)](https://travis-ci.com/Cryptonite-UO/CryptoCore) (Travis)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/a644ed6dd6be4f1cbfc27dc97ea2cab2)](https://app.codacy.com/gh/Cryptonite-UO/CryptoCore?utm_source=github.com&utm_medium=referral&utm_content=Cryptonite-UO/CryptoCore&utm_campaign=Badge_Grade_Settings)
# CRYPTOCORE
This Repository is a Clone of the SphereServer X version available here: [SOURCEX](https://github.com/Sphereserver/Source-X) 

## Why a clone/fork?
This version of Sphere is use on Ultima online [Cryptonite Shard](https://www.uocryptonite.com/).
We decide to fork this branch because some little modification are made for adapting our gameplay.


#### Here the list of difference between the reel sphere X:
[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/d5058e6ad5665c282cfb287a9b0653d721aacc3a) 2023-03-23
1.  It's now possible to hide and detect hidden during battle. This action will result to reset all actual action.

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/ee5efa6ec1f80fdb12bb503e0165c78d54607e85) 2023-03-14
1.  Str damage boost is now 2% instead of 10%

[Commit](https://github.com/Cryptonite-UO/CryptoCore/commit/940a70dfbf07d5d713b1b8afff5738ad8af95b00) 2021-01-10
1.  Insubtantial flags is use on some class (CL) you can now pass trought him. (partial Revert of commit of december)

[Commit](https://github.com/Cryptonite-UO/CryptoCore/commit/646bd299a0680b02bf70a12f36c703fd925f8796) 2020-12-10
1.  Cryptonite use c_gargoyle_male and female as custom dwarf. We need to avoid the gargoyle anim and force human anim.
2.  Insubtantial flags is use on some class (CL) during a small period. We must modify  that the player is see like a death player.
3.  Emote message over NPC/player head is crap and long. "YOU SEE NAME" is useless. We remove all name and pronom. (important to modify msg.scp in script too)

