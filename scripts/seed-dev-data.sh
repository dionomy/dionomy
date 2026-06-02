#!/usr/bin/env zsh
set -euo pipefail

node <<'NODE'
const apiBaseUrl = process.env.DIONOMY_API_BASE_URL || 'http://localhost:8080';
const tenantId = process.env.DIONOMY_TENANT_ID || process.env.VITE_DIONOMY_TENANT_ID || '00000000-0000-0000-0000-000000000001';
const teacherId = process.env.DIONOMY_SEED_TEACHER_ID || '00000000-0000-0000-0000-000000000101';
const placeId = process.env.DIONOMY_SEED_PLACE_ID || '00000000-0000-0000-0000-000000000201';
const forceSeed = process.env.FORCE_SEED === '1';

const headers = {
  'Content-Type': 'application/json',
  'X-Tenant-Id': tenantId,
};

function dateString(offsetDays) {
  const date = new Date();
  date.setDate(date.getDate() + offsetDays);
  return date.toISOString().slice(0, 10);
}

function dateTimeString(offsetDays, hour, minute = 0) {
  return `${dateString(offsetDays)}T${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}:00`;
}

async function request(path, options = {}) {
  const response = await fetch(`${apiBaseUrl}${path}`, {
    ...options,
    headers: {
      ...headers,
      ...(options.headers || {}),
    },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`${options.method || 'GET'} ${path} failed (${response.status}) ${body}`);
  }

  if (response.status === 204) {
    return null;
  }

  return response.json();
}

async function post(path, body) {
  return request(path, {
    method: 'POST',
    body: JSON.stringify(body),
  });
}

async function main() {
  try {
    await request('/health', { headers: { 'Content-Type': 'application/json' } });
  } catch (error) {
    console.error(`[error] backend API에 연결할 수 없습니다: ${apiBaseUrl}`);
    console.error('[action] 먼저 just dev 또는 just backend-dev를 실행하세요.');
    throw error;
  }

  const existingStudents = await request('/api/students');
  const existingProducts = await request('/api/pass-products');
  const existingSchedules = await request(`/api/schedules?from=${dateString(-1)}&to=${dateString(14)}`);

  if (!forceSeed && existingStudents.length > 0 && existingProducts.length > 0 && existingSchedules.length > 0) {
    console.log('[ok] 개발용 샘플 데이터가 이미 있습니다.');
    console.log('[hint] 다시 넣으려면 FORCE_SEED=1 just seed');
    return;
  }

  const students = [];
  for (const student of [
    { name: '김민지', phone: '010-1000-0001', memo: '기타 입문반. 재등록 의사 있음.', tags: ['초보', '재등록 의사'] },
    { name: '박서준', phone: '010-1000-0002', memo: '최근 결석 신청. 보강 선호.', tags: ['보강 필요'] },
    { name: '이가은', phone: '010-1000-0003', memo: '신규 정착 관리 대상.', tags: ['신규'] },
  ]) {
    students.push(await post('/api/students', student));
  }

  const product = await post('/api/pass-products', {
    name: '4주 8회 수강권',
    totalCount: 8,
    validDays: 28,
    price: 180000,
  });

  const issuedPasses = [];
  for (const [index, student] of students.entries()) {
    issuedPasses.push(await post(`/api/students/${student.id}/passes`, {
      productId: product.id,
      issuedOn: dateString(index === 0 ? -24 : index === 1 ? -10 : -3),
    }));
  }

  await post(`/api/student-passes/${issuedPasses[0].id}/consume`, { count: 7, reason: '개발 시드: 출석 차감' });
  await post(`/api/student-passes/${issuedPasses[1].id}/consume`, { count: 2, reason: '개발 시드: 출석 차감' });

  const groupSession = await post('/api/schedules', {
    title: '화요 기타 입문반',
    type: 'GROUP',
    teacherId,
    placeId,
    startsAt: dateTimeString(0, 19),
    endsAt: dateTimeString(0, 20),
    currentCapacity: students.length,
    maximumCapacity: 5,
    assignedStudentIds: students.map((student) => student.id),
    recurrence: null,
  });

  const privateSession = await post('/api/schedules', {
    title: '1:1 보컬 코칭',
    type: 'ONE_ON_ONE',
    teacherId,
    placeId,
    startsAt: dateTimeString(1, 20, 30),
    endsAt: dateTimeString(1, 21, 30),
    currentCapacity: 1,
    maximumCapacity: 1,
    assignedStudentIds: [students[1].id],
    recurrence: null,
  });

  await post(`/api/attendance/sessions/${groupSession.id}`, {
    studentId: students[0].id,
    teacherId,
    status: 'PRESENT',
  });
  await post(`/api/attendance/sessions/${groupSession.id}`, {
    studentId: students[1].id,
    teacherId,
    status: 'LATE',
  });

  await post('/api/class-notes', {
    sessionId: groupSession.id,
    teacherId,
    progress: '기본 코드 전환과 리듬 패턴 연습',
    feedback: '코드 전환 속도는 안정적이고, 박자 유지 연습이 필요합니다.',
    nextAssignment: 'G-C-D 코드 전환 10분 반복',
  });

  await post('/api/notices', {
    title: '6월 운영 안내',
    body: '이번 주 정규 수업은 정상 진행됩니다. 결석 신청은 수업 전까지 앱에서 남겨주세요.',
    imageUrl: null,
    target: 'ALL',
    classId: null,
  });

  await post('/api/absence-requests', {
    studentId: students[1].id,
    sessionId: privateSession.id,
    reason: '개인 일정으로 참석이 어렵습니다.',
    desiredResult: 'MAKEUP',
  });

  const summary = await request('/api/students/operation-summary');

  console.log('[ok] 개발용 샘플 데이터 생성 완료');
  console.log(`students=${students.length} product=${product.id}`);
  console.log(`groupSession=${groupSession.id}`);
  console.log(`privateSession=${privateSession.id}`);
  console.log(`operationSummary.totalStudents=${summary.totalStudents}`);
  console.log(`operationSummary.passExpiringSoonCount=${summary.passExpiringSoonCount}`);
  console.log(`operationSummary.passLowRemainingCount=${summary.passLowRemainingCount}`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
NODE
