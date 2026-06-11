#!/bin/bash
# Mayoty FlowSim — 멀티워치 풀게임 인메모리 시뮬레이션
# 사용법: bash Tools/FlowSim/run.sh
set -e

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP="$ROOT/Mayoty/Mayoty"
WATCH="$ROOT/Mayoty/MayotyWatch Watch App"
OUT="${TMPDIR:-/tmp}/flowsim"

xcrun swiftc -swift-version 5 -o "$OUT" \
  "$APP/Core/GameLogger.swift" \
  "$APP/Domain/MafiaGame.swift" \
  "$APP/Domain/GameAction.swift" \
  "$APP/Domain/GameRule.swift" \
  "$APP/Domain/Entities/Player.swift" \
  "$APP/Domain/Entities/PlayerColor.swift" \
  "$APP/Domain/Entities/Team.swift" \
  "$APP/Domain/Roles/Role.swift" \
  "$APP/Domain/States/GameState.swift" \
  "$APP/Domain/States/WaitingState.swift" \
  "$APP/Domain/States/RoleAssigningState.swift" \
  "$APP/Domain/States/IntroductionState.swift" \
  "$APP/Domain/States/NightState.swift" \
  "$APP/Domain/States/MafiaState.swift" \
  "$APP/Domain/States/PoliceState.swift" \
  "$APP/Domain/States/DoctorState.swift" \
  "$APP/Domain/States/DiscussionState.swift" \
  "$APP/Domain/States/VoteState.swift" \
  "$APP/Domain/States/FinalDefenseState.swift" \
  "$APP/Domain/States/ExecutionVoteState.swift" \
  "$APP/Domain/States/ExecutionResultState.swift" \
  "$APP/Domain/States/ResultState.swift" \
  "$APP/Domain/Services/VoteManager.swift" \
  "$APP/Domain/Services/TimerManager.swift" \
  "$APP/Domain/Services/RoleManager.swift" \
  "$APP/Domain/Services/ColorManager.swift" \
  "$APP/Domain/Services/ResultManager.swift" \
  "$APP/Domain/Services/GameRuleManager.swift" \
  "$APP/Domain/Services/SoundManager.swift" \
  "$APP/Infrastructure/Bluetooth/Common/BLECommand.swift" \
  "$APP/Infrastructure/Bluetooth/Common/BLEAnswer.swift" \
  "$APP/Infrastructure/Bluetooth/Peripheral/WatchCommandManager.swift" \
  "$APP/Infrastructure/Bluetooth/Peripheral/BLECommandQueue.swift" \
  "$APP/Infrastructure/Bluetooth/Peripheral/BLEViewModel.swift" \
  "$WATCH/Core/WatchCommandStore.swift" \
  "$WATCH/Core/Model/WatchScreen.swift" \
  "$WATCH/Core/Model/Role+Watch.swift" \
  "$WATCH/Core/ExecutionResult.swift" \
  "$ROOT/Tools/FlowSim/Stubs.swift" \
  "$ROOT/Tools/FlowSim/Scenario.swift"

echo "빌드 완료 — 시뮬레이션 시작"
"$OUT"
