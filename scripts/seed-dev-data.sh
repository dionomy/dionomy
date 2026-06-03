#!/usr/bin/env zsh
set -euo pipefail

set -a
source .env
set +a

docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null <<'SQL'
insert into tenants (id, academy_number, name, status)
values
    ('00000000-0000-0000-0000-000000000002', 2, '리듬앤무브 댄스스튜디오', 'ACTIVE'),
    ('00000000-0000-0000-0000-000000000003', 3, '어반드로잉 클래스', 'ACTIVE')
on conflict (id) do update
set academy_number = excluded.academy_number,
    name = excluded.name,
    status = excluded.status;

insert into academy_settings (
    tenant_id,
    name,
    contact,
    address,
    logo_url,
    main_color,
    extension_allowed,
    refund_allowed,
    makeup_enabled,
    makeup_expires_in_days,
    makeup_max_count,
    owner_schedule_enabled,
    owner_students_enabled,
    owner_notices_enabled,
    teacher_mode_enabled,
    student_pass_enabled,
    student_class_notes_enabled,
    student_absence_request_enabled,
    crm_enabled
)
values
    ('00000000-0000-0000-0000-000000000002', '리듬앤무브 댄스스튜디오', '02-222-0002', '서울시 마포구 와우산로 12', null, '#1F8A5B', true, false, true, 14, 3, true, true, true, true, true, false, true, true),
    ('00000000-0000-0000-0000-000000000003', '어반드로잉 클래스', '02-333-0003', '서울시 성동구 왕십리로 45', null, '#D97706', false, false, false, 0, 0, true, true, true, false, true, true, false, true)
on conflict (tenant_id) do update
set name = excluded.name,
    contact = excluded.contact,
    address = excluded.address,
    main_color = excluded.main_color,
    extension_allowed = excluded.extension_allowed,
    refund_allowed = excluded.refund_allowed,
    makeup_enabled = excluded.makeup_enabled,
    makeup_expires_in_days = excluded.makeup_expires_in_days,
    makeup_max_count = excluded.makeup_max_count,
    owner_schedule_enabled = excluded.owner_schedule_enabled,
    owner_students_enabled = excluded.owner_students_enabled,
    owner_notices_enabled = excluded.owner_notices_enabled,
    teacher_mode_enabled = excluded.teacher_mode_enabled,
    student_pass_enabled = excluded.student_pass_enabled,
    student_class_notes_enabled = excluded.student_class_notes_enabled,
    student_absence_request_enabled = excluded.student_absence_request_enabled,
    crm_enabled = excluded.crm_enabled;

insert into instructors (id, tenant_id, name, phone)
values
    ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000002', '정하린 강사', '010-5000-0002'),
    ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000003', '서도현 강사', '010-5000-0003')
on conflict (id) do update
set name = excluded.name,
    phone = excluded.phone;

insert into places (id, tenant_id, name, memo)
values
    ('00000000-0000-0000-0000-000000000202', '00000000-0000-0000-0000-000000000002', '댄스룸 A', '전면 거울과 스피커가 있는 그룹 수업 공간'),
    ('00000000-0000-0000-0000-000000000203', '00000000-0000-0000-0000-000000000003', '드로잉룸 1', '개별 이젤과 채광이 좋은 드로잉 공간')
on conflict (id) do update
set name = excluded.name,
    memo = excluded.memo;
SQL

node <<'NODE'
const apiBaseUrl = process.env.DIONOMY_API_BASE_URL || 'http://localhost:8080';
let activeTenantId = process.env.DIONOMY_TENANT_ID || process.env.VITE_DIONOMY_TENANT_ID || '00000000-0000-0000-0000-000000000001';
let activeTeacherId = process.env.DIONOMY_SEED_TEACHER_ID || '00000000-0000-0000-0000-000000000101';
let activePlaceId = process.env.DIONOMY_SEED_PLACE_ID || '00000000-0000-0000-0000-000000000201';

const headers = {
  'Content-Type': 'application/json',
};

const created = {
  students: 0,
  products: 0,
  passes: 0,
  schedules: 0,
  attendance: 0,
  classNotes: 0,
  notices: 0,
  absenceRequests: 0,
  careRecords: 0,
  company: 0,
  adminSetups: 0,
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
      'X-Tenant-Id': activeTenantId,
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

async function ensureItem(listPath, match, createPath, body, counterName) {
  const items = await request(listPath);
  const existing = items.find(match);
  if (existing) {
    return existing;
  }

  const item = await post(createPath, body);
  created[counterName] += 1;
  return item;
}

async function ensureStudent(student) {
  return ensureItem('/api/students', (item) => item.phone === student.phone || item.name === student.name, '/api/students', student, 'students');
}

async function ensureProduct(product) {
  return ensureItem('/api/pass-products', (item) => item.name === product.name, '/api/pass-products', product, 'products');
}

async function ensurePass(student, product, issuedOn, consumeCount = 0) {
  const passes = await request(`/api/students/${student.id}/passes`);
  const existing = passes.find((pass) => pass.productId === product.id);
  if (existing) {
    return existing;
  }

  const pass = await post(`/api/students/${student.id}/passes`, {
    productId: product.id,
    issuedOn,
  });
  created.passes += 1;

  if (consumeCount > 0) {
    await post(`/api/student-passes/${pass.id}/consume`, {
      count: consumeCount,
      reason: '개발 시드: 출석 차감',
    });
  }

  return pass;
}

async function ensureSchedule(session) {
  const sessions = await request(`/api/schedules?from=${dateString(-14)}&to=${dateString(30)}`);
  const existing = sessions.find((item) => item.title === session.title && item.startsAt === session.startsAt);
  if (existing) {
    return existing;
  }

  const createdSession = await post('/api/schedules', session);
  created.schedules += 1;
  return createdSession;
}

async function ensureAttendance(session, student, status) {
  const records = await request(`/api/attendance/sessions/${session.id}`);
  const existing = records.find((record) => record.studentId === student.id);
  if (existing) {
    return existing;
  }

  const record = await post(`/api/attendance/sessions/${session.id}`, {
    studentId: student.id,
    teacherId: activeTeacherId,
    status,
  });
  created.attendance += 1;
  return record;
}

async function ensureClassNote(note) {
  const notes = await request(`/api/class-notes?sessionId=${note.sessionId}`);
  const existing = notes.find((item) => item.progress === note.progress);
  if (existing) {
    return existing;
  }

  const createdNote = await post('/api/class-notes', note);
  created.classNotes += 1;
  return createdNote;
}

async function ensureNotice(notice) {
  return ensureItem('/api/notices', (item) => item.title === notice.title, '/api/notices', notice, 'notices');
}

async function ensureAbsenceRequest(absenceRequest) {
  const requests = await request('/api/absence-requests');
  const existing = requests.find((item) => item.studentId === absenceRequest.studentId && item.sessionId === absenceRequest.sessionId);
  if (existing) {
    return existing;
  }

  const createdRequest = await post('/api/absence-requests', absenceRequest);
  created.absenceRequests += 1;
  return createdRequest;
}

async function ensureCareRecord(student, careRecord) {
  const records = await request(`/api/crm/students/${student.id}/care-records`);
  const existing = records.find((item) => item.memo === careRecord.memo);
  if (existing) {
    return existing;
  }

  const createdRecord = await post(`/api/crm/students/${student.id}/care-records`, careRecord);
  created.careRecords += 1;
  return createdRecord;
}

async function ensureCompanySamples() {
  for (const demoRequest of [
    { academyName: '리듬앤무브 댄스스튜디오', businessType: '댄스', academySize: '강사 4명 / 수강생 80명', contact: '010-2000-0001' },
    { academyName: '어반드로잉 클래스', businessType: '미술', academySize: '강사 2명 / 수강생 35명', contact: '010-2000-0002' },
  ]) {
    await ensureItem('/api/company/demo-requests', (item) => item.contact === demoRequest.contact, '/api/company/demo-requests', demoRequest, 'company');
  }

  for (const ticket of [
    { title: '화이트라벨 앱 색상 변경 문의', body: '브랜드 메인 컬러를 다음 달부터 변경하고 싶습니다.', contact: '010-3000-0001' },
    { title: '결석 신청 승인 알림 문의', body: '강사가 승인했을 때 수강생 화면에서 상태가 바로 보이는지 확인 부탁드립니다.', contact: '010-3000-0002' },
  ]) {
    await ensureItem('/api/company/cs-tickets', (item) => item.contact === ticket.contact && item.title === ticket.title, '/api/company/cs-tickets', ticket, 'company');
  }
}

async function ensureAdminSamples() {
  for (const setup of [
    { academyName: '스튜디오 포르테', ownerContact: '010-4000-0001', mainColor: '#2F6BFF' },
    { academyName: '그린테니스 아카데미', ownerContact: '010-4000-0002', mainColor: '#1F8A5B' },
  ]) {
    await ensureItem('/api/admin/tenant-setups', (item) => item.ownerContact === setup.ownerContact, '/api/admin/tenant-setups', setup, 'adminSetups');
  }
}

function setAcademyContext(context) {
  activeTenantId = context.tenantId;
  activeTeacherId = context.teacherId;
  activePlaceId = context.placeId;
}

async function seedCompactAcademy(context) {
  setAcademyContext(context);

  const localStudents = {};
  for (const student of context.students) {
    const { key, ...payload } = student;
    localStudents[key] = await ensureStudent(payload);
  }

  const product = await ensureProduct(context.product);
  for (const pass of context.passes) {
    await ensurePass(localStudents[pass.studentKey], product, dateString(pass.issuedOffsetDays), pass.consumeCount);
  }

  const sessions = {};
  for (const session of context.sessions) {
    sessions[session.key] = await ensureSchedule({
      title: session.title,
      type: session.type,
      teacherId: activeTeacherId,
      placeId: activePlaceId,
      startsAt: dateTimeString(session.startsOffsetDays, session.startsHour, session.startsMinute ?? 0),
      endsAt: dateTimeString(session.startsOffsetDays, session.endsHour, session.endsMinute ?? 0),
      currentCapacity: session.studentKeys.length,
      maximumCapacity: session.maximumCapacity,
      assignedStudentIds: session.studentKeys.map((studentKey) => localStudents[studentKey].id),
      recurrence: null,
    });
  }

  for (const attendance of context.attendance) {
    await ensureAttendance(sessions[attendance.sessionKey], localStudents[attendance.studentKey], attendance.status);
  }

  for (const note of context.classNotes) {
    await ensureClassNote({
      sessionId: sessions[note.sessionKey].id,
      teacherId: activeTeacherId,
      progress: note.progress,
      feedback: note.feedback,
      nextAssignment: note.nextAssignment,
    });
  }

  for (const notice of context.notices) {
    await ensureNotice({
      title: notice.title,
      body: notice.body,
      imageUrl: null,
      target: 'ALL',
      classId: null,
    });
  }

  for (const absenceRequest of context.absenceRequests) {
    await ensureAbsenceRequest({
      studentId: localStudents[absenceRequest.studentKey].id,
      sessionId: sessions[absenceRequest.sessionKey].id,
      reason: absenceRequest.reason,
      desiredResult: absenceRequest.desiredResult,
    });
  }

  await post('/api/crm/retention-signals/refresh', {});
}

async function main() {
  try {
    await request('/health', { headers: { 'Content-Type': 'application/json' } });
  } catch (error) {
    console.error(`[error] backend API에 연결할 수 없습니다: ${apiBaseUrl}`);
    console.error('[action] 먼저 just dev 또는 just backend-dev를 실행하세요.');
    throw error;
  }

  setAcademyContext({
    tenantId: '00000000-0000-0000-0000-000000000001',
    teacherId: '00000000-0000-0000-0000-000000000101',
    placeId: '00000000-0000-0000-0000-000000000201',
  });

  const students = {};
  for (const student of [
    { key: 'minji', name: '김민지', phone: '010-1000-0001', memo: '기타 입문반. 재등록 의사 있음.', tags: ['초보', '재등록 의사'] },
    { key: 'seojoon', name: '박서준', phone: '010-1000-0002', memo: '최근 결석 신청. 보강 선호.', tags: ['보강 필요'] },
    { key: 'gaeun', name: '이가은', phone: '010-1000-0003', memo: '신규 정착 관리 대상.', tags: ['신규'] },
    { key: 'hyunwoo', name: '정현우', phone: '010-1000-0004', memo: '1:1 보컬 코칭. 야간 시간 선호.', tags: ['1:1', '야간'] },
    { key: 'sora', name: '최소라', phone: '010-1000-0005', memo: '댄스 그룹반. 출석률 안정적.', tags: ['그룹', '우수출석'] },
    { key: 'yujin', name: '한유진', phone: '010-1000-0006', memo: '수강권 만료 후 재등록 상담 필요.', tags: ['만료임박', '상담필요'] },
    { key: 'doyoon', name: '오도윤', phone: '010-1000-0007', memo: '보강 누적 관리 대상.', tags: ['보강누적'] },
    { key: 'arin', name: '문아린', phone: '010-1000-0008', memo: '주말 수업만 가능.', tags: ['주말'] },
  ]) {
    const { key, ...payload } = student;
    students[key] = await ensureStudent(payload);
  }

  const fourWeekPass = await ensureProduct({ name: '4주 8회 수강권', totalCount: 8, validDays: 28, price: 180000 });
  const eightWeekPass = await ensureProduct({ name: '8주 16회 수강권', totalCount: 16, validDays: 56, price: 320000 });

  await ensurePass(students.minji, fourWeekPass, dateString(-24), 7);
  await ensurePass(students.seojoon, fourWeekPass, dateString(-10), 2);
  await ensurePass(students.gaeun, fourWeekPass, dateString(-3), 0);
  await ensurePass(students.hyunwoo, eightWeekPass, dateString(-14), 4);
  await ensurePass(students.sora, eightWeekPass, dateString(-20), 6);
  await ensurePass(students.yujin, fourWeekPass, dateString(-25), 6);
  await ensurePass(students.doyoon, fourWeekPass, dateString(-18), 5);
  await ensurePass(students.arin, eightWeekPass, dateString(-7), 1);

  const guitarSession = await ensureSchedule({
    title: '화요 기타 입문반',
    type: 'GROUP',
    teacherId: activeTeacherId,
    placeId: activePlaceId,
    startsAt: dateTimeString(0, 19),
    endsAt: dateTimeString(0, 20),
    currentCapacity: 4,
    maximumCapacity: 5,
    assignedStudentIds: [students.minji.id, students.seojoon.id, students.gaeun.id, students.sora.id],
    recurrence: null,
  });

  const vocalSession = await ensureSchedule({
    title: '1:1 보컬 코칭',
    type: 'ONE_ON_ONE',
    teacherId: activeTeacherId,
    placeId: activePlaceId,
    startsAt: dateTimeString(1, 20, 30),
    endsAt: dateTimeString(1, 21, 30),
    currentCapacity: 1,
    maximumCapacity: 1,
    assignedStudentIds: [students.hyunwoo.id],
    recurrence: null,
  });

  const danceSession = await ensureSchedule({
    title: '목요 K-POP 댄스반',
    type: 'GROUP',
    teacherId: activeTeacherId,
    placeId: activePlaceId,
    startsAt: dateTimeString(2, 18, 30),
    endsAt: dateTimeString(2, 19, 50),
    currentCapacity: 3,
    maximumCapacity: 8,
    assignedStudentIds: [students.sora.id, students.yujin.id, students.doyoon.id],
    recurrence: null,
  });

  const weekendSession = await ensureSchedule({
    title: '토요 드로잉 클래스',
    type: 'GROUP',
    teacherId: activeTeacherId,
    placeId: activePlaceId,
    startsAt: dateTimeString(3, 11),
    endsAt: dateTimeString(3, 12, 30),
    currentCapacity: 2,
    maximumCapacity: 6,
    assignedStudentIds: [students.arin.id, students.gaeun.id],
    recurrence: null,
  });

  await ensureAttendance(guitarSession, students.minji, 'PRESENT');
  await ensureAttendance(guitarSession, students.seojoon, 'LATE');
  await ensureAttendance(guitarSession, students.gaeun, 'ABSENT');
  await ensureAttendance(danceSession, students.sora, 'PRESENT');
  await ensureAttendance(danceSession, students.yujin, 'PRESENT');

  await ensureClassNote({
    sessionId: guitarSession.id,
    teacherId: activeTeacherId,
    progress: '기본 코드 전환과 리듬 패턴 연습',
    feedback: '코드 전환 속도는 안정적이고, 박자 유지 연습이 필요합니다.',
    nextAssignment: 'G-C-D 코드 전환 10분 반복',
  });
  await ensureClassNote({
    sessionId: danceSession.id,
    teacherId: activeTeacherId,
    progress: '후렴 8카운트 동작 연결',
    feedback: '상체 라인은 좋아졌고, 발 위치를 더 좁혀야 합니다.',
    nextAssignment: '후렴 파트 영상 보고 3회 반복',
  });
  await ensureClassNote({
    sessionId: weekendSession.id,
    teacherId: activeTeacherId,
    progress: '명암 단계와 구도 잡기',
    feedback: '구도는 안정적이고, 중간톤 사용을 늘리면 좋습니다.',
    nextAssignment: '컵 스케치 2장',
  });

  await ensureNotice({
    title: '6월 운영 안내',
    body: '이번 주 정규 수업은 정상 진행됩니다. 결석 신청은 수업 전까지 앱에서 남겨주세요.',
    imageUrl: null,
    target: 'ALL',
    classId: null,
  });
  await ensureNotice({
    title: '여름 시즌 보강 정책 안내',
    body: '보강은 결석 승인일로부터 14일 이내 사용 가능합니다. 강사 승인 후 일정이 확정됩니다.',
    imageUrl: null,
    target: 'ALL',
    classId: null,
  });
  await ensureNotice({
    title: '주말반 준비물 안내',
    body: '토요 드로잉 클래스는 4B 연필과 지우개를 준비해주세요.',
    imageUrl: null,
    target: 'CLASS',
    classId: weekendSession.id,
  });

  await ensureAbsenceRequest({
    studentId: students.seojoon.id,
    sessionId: vocalSession.id,
    reason: '개인 일정으로 참석이 어렵습니다.',
    desiredResult: 'MAKEUP',
  });
  await ensureAbsenceRequest({
    studentId: students.doyoon.id,
    sessionId: danceSession.id,
    reason: '출장 일정으로 당일 수업 참석이 어렵습니다.',
    desiredResult: 'MOVE_TO_OTHER_SESSION',
  });

  await post('/api/crm/retention-signals/refresh', {});
  await ensureCareRecord(students.minji, { memo: '잔여 1회와 기간 임박 안내. 재등록 의사 확인 필요.', status: 'CONTACTED' });
  await ensureCareRecord(students.yujin, { memo: '수강권 만료 전 재등록 상담 예약 요청.', status: 'PENDING' });
  await ensureCareRecord(students.doyoon, { memo: '보강 누적 원인 확인 필요.', status: 'PENDING' });

  await ensureCompanySamples();
  await ensureAdminSamples();

  await seedCompactAcademy({
    tenantId: '00000000-0000-0000-0000-000000000002',
    teacherId: '00000000-0000-0000-0000-000000000102',
    placeId: '00000000-0000-0000-0000-000000000202',
    students: [
      { key: 'nari', name: '강나리', phone: '010-1200-0001', memo: 'K-POP 입문반. 움직임이 빠름.', tags: ['댄스', '입문'] },
      { key: 'jiho', name: '배지호', phone: '010-1200-0002', memo: '보강 요청이 잦아 일정 관리 필요.', tags: ['보강관리'] },
      { key: 'yeseo', name: '윤예서', phone: '010-1200-0003', memo: '정규반 재등록 가능성 높음.', tags: ['재등록 의사'] },
      { key: 'minseok', name: '차민석', phone: '010-1200-0004', memo: '개인 레슨 선호.', tags: ['1:1'] },
    ],
    product: { name: '댄스 4주 8회권', totalCount: 8, validDays: 28, price: 220000 },
    passes: [
      { studentKey: 'nari', issuedOffsetDays: -8, consumeCount: 3 },
      { studentKey: 'jiho', issuedOffsetDays: -22, consumeCount: 6 },
      { studentKey: 'yeseo', issuedOffsetDays: -4, consumeCount: 1 },
      { studentKey: 'minseok', issuedOffsetDays: -18, consumeCount: 4 },
    ],
    sessions: [
      { key: 'kpop', title: '월요 K-POP 베이직', type: 'GROUP', startsOffsetDays: 1, startsHour: 19, endsHour: 20, maximumCapacity: 8, studentKeys: ['nari', 'jiho', 'yeseo'] },
      { key: 'private', title: '1:1 퍼포먼스 코칭', type: 'ONE_ON_ONE', startsOffsetDays: 2, startsHour: 20, startsMinute: 30, endsHour: 21, endsMinute: 30, maximumCapacity: 1, studentKeys: ['minseok'] },
    ],
    attendance: [
      { sessionKey: 'kpop', studentKey: 'nari', status: 'PRESENT' },
      { sessionKey: 'kpop', studentKey: 'jiho', status: 'ABSENT' },
    ],
    classNotes: [
      { sessionKey: 'kpop', progress: '후렴 파트 16카운트 연결', feedback: '동작 연결은 좋아졌고, 시선 처리가 필요합니다.', nextAssignment: '거울 보고 후렴 3회 반복' },
    ],
    notices: [
      { title: '댄스룸 이용 안내', body: '수업 시작 10분 전부터 입장 가능합니다. 실내용 운동화를 준비해주세요.' },
    ],
    absenceRequests: [
      { sessionKey: 'private', studentKey: 'minseok', reason: '야근으로 참석이 어렵습니다.', desiredResult: 'MAKEUP' },
    ],
  });

  await seedCompactAcademy({
    tenantId: '00000000-0000-0000-0000-000000000003',
    teacherId: '00000000-0000-0000-0000-000000000103',
    placeId: '00000000-0000-0000-0000-000000000203',
    students: [
      { key: 'haeun', name: '신하은', phone: '010-1300-0001', memo: '기초 소묘반. 주말 선호.', tags: ['드로잉', '주말'] },
      { key: 'taeho', name: '김태호', phone: '010-1300-0002', memo: '수강권 만료 임박.', tags: ['만료임박'] },
      { key: 'eunbin', name: '정은빈', phone: '010-1300-0003', memo: '클래스노트 확인 빈도 높음.', tags: ['성실'] },
    ],
    product: { name: '드로잉 6주 6회권', totalCount: 6, validDays: 42, price: 150000 },
    passes: [
      { studentKey: 'haeun', issuedOffsetDays: -12, consumeCount: 2 },
      { studentKey: 'taeho', issuedOffsetDays: -38, consumeCount: 5 },
      { studentKey: 'eunbin', issuedOffsetDays: -6, consumeCount: 1 },
    ],
    sessions: [
      { key: 'drawing', title: '수요 기초 소묘', type: 'GROUP', startsOffsetDays: 1, startsHour: 18, endsHour: 19, endsMinute: 30, maximumCapacity: 6, studentKeys: ['haeun', 'taeho', 'eunbin'] },
      { key: 'weekend', title: '토요 어반스케치', type: 'GROUP', startsOffsetDays: 4, startsHour: 10, endsHour: 12, maximumCapacity: 8, studentKeys: ['haeun', 'eunbin'] },
    ],
    attendance: [
      { sessionKey: 'drawing', studentKey: 'haeun', status: 'PRESENT' },
      { sessionKey: 'drawing', studentKey: 'taeho', status: 'LATE' },
    ],
    classNotes: [
      { sessionKey: 'drawing', progress: '원기둥 명암과 투시', feedback: '형태 관찰이 좋아졌고 중간톤을 더 써보면 좋습니다.', nextAssignment: '원기둥 스케치 2장' },
    ],
    notices: [
      { title: '드로잉 준비물 안내', body: '4B 연필, 지우개, A4 스케치북을 준비해주세요.' },
    ],
    absenceRequests: [
      { sessionKey: 'weekend', studentKey: 'haeun', reason: '가족 일정으로 참석이 어렵습니다.', desiredResult: 'MOVE_TO_OTHER_SESSION' },
    ],
  });

  setAcademyContext({
    tenantId: '00000000-0000-0000-0000-000000000001',
    teacherId: '00000000-0000-0000-0000-000000000101',
    placeId: '00000000-0000-0000-0000-000000000201',
  });

  const summary = await request('/api/students/operation-summary');
  const schedules = await request(`/api/schedules?from=${dateString(-14)}&to=${dateString(30)}`);
  const notices = await request('/api/notices');
  const absenceRequests = await request('/api/absence-requests');
  const riskStudents = await request('/api/crm/risk-students');

  console.log('[ok] 개발용 샘플 데이터 준비 완료');
  console.log(`created=${JSON.stringify(created)}`);
  console.log(`students=${summary.totalStudents}`);
  console.log(`passExpiringSoonCount=${summary.passExpiringSoonCount}`);
  console.log(`passLowRemainingCount=${summary.passLowRemainingCount}`);
  console.log(`schedules=${schedules.length}`);
  console.log(`notices=${notices.length}`);
  console.log(`absenceRequests=${absenceRequests.length}`);
  console.log(`riskStudents=${riskStudents.length}`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
NODE
