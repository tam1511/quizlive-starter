# QuizLive

Game quiz trực tiếp do AI sinh câu hỏi, được xây bằng một **đội AI agent** cùng làm việc với Claude Code.

Đây là repo đi kèm video **Vibe Code Pro #3** (Sub-agent, Agent Teams, Hooks & Sandbox).

- Video: [[link video #3](https://youtu.be/8WE8fxVWjXk)]
- Series: [#1 Quy trình dùng Claude Code để xây app thật](https://youtu.be/GrCKwtz49Js?si=sh0g3ThYeBLu5oco) | [#2 Nâng cấp Claude Code với MCP, Skills & Plugins](https://youtu.be/2zBGKaYmSX0?si=azn1dO-XQ9cAQli2) | #3 (video này)

## QuizLive là gì?

1. Host mở trang chủ trên máy chiếu, nhập một chủ đề (ví dụ "Hệ mặt trời"), bấm **Tạo phòng**.
2. AI sinh 5 câu hỏi, màn hình hiện mã phòng và mã QR.
3. Người chơi nhập mã hoặc quét QR để tham gia từ điện thoại.
4. Điểm tính theo tốc độ: trả lời càng nhanh càng nhiều điểm.
5. Cuối ván có bảng xếp hạng.

Nguyên tắc thiết kế: đơn giản trước. Không tài khoản, không chọn số câu, không build step, không Node. Việc nào không có trong `planning/SPEC.md` thì không tự thêm.

## Mục tiêu học tập của video

Trả lời câu hỏi: **làm sao để nhiều agent cùng làm một việc lớn mà không agent nào bị quá tải hay phá việc của agent khác, và mình vẫn là người nắm quyền quyết định?**

Video dùng khung **3 ranh giới của agent**:

| Ranh giới | Câu hỏi | Công cụ trong video |
|---|---|---|
| Context | Agent đang nhìn thấy gì? | Sub-agent, `CLAUDE.md`, hook `SessionStart` |
| Permission | Agent được phép chạm vào đâu? | `/permissions` (Deny), Sandbox |
| Conversation | Các agent nói chuyện với nhau thế nào? | Agent Teams, `CONTRACT.md`, `STATE.md` |

Các khái niệm này áp dụng được cho Codex, opencode hay agent tự build, không chỉ Claude Code.

## Cấu trúc dự án

```
quizlive/
├── CLAUDE.md                  # Ngắn gọn: dự án là gì, môi trường, kiến trúc, quy ước
├── planning/
│   ├── CONTRACT.md            # "Hợp đồng": dữ liệu, API, trạng thái phòng. Luôn nằm trong context (@)
│   ├── SPEC.md                # Mô tả sản phẩm đầy đủ, 3 luật không được phá, bảng phân công
│   ├── STATE.md               # Dự án đang ở đâu. Chỉ trưởng nhóm được sửa
│   └── research/
│       └── scoring.md         # Kết quả cuộc tranh luận của agent team về cách tính điểm
├── tests/
│   └── invariants/            # 3 bài test "trọng tài", đã khóa bằng Deny rules
├── backend/
│   └── generator.py           # File duy nhất được gọi LLM
├── frontend/                  # HTML/CSS/JS tĩnh, FastAPI phục vụ
├── .claude/
│   ├── settings.json          # Hooks + bật Agent Teams
│   └── agents/
│       └── leak-hunter.md     # Sub-agent dò đường rò rỉ đáp án
├── Dockerfile
└── requirements.txt           # Nơi duy nhất khai báo dependency
```

> Cấu trúc thực tế có thể khác đôi chút tùy bước bạn đang ở. Xem `planning/STATE.md` để biết tiến độ.

## Bốn file nền móng

Hệ thống file là **bộ nhớ chung** của cả đội agent.

- **`CLAUDE.md`**: Claude đọc mỗi khi bắt đầu. Giữ thật ngắn. Dùng `@planning/CONTRACT.md` để luôn nạp hợp đồng vào context; file dài và chỉ thỉnh thoảng cần (như `SPEC.md`) thì chỉ nhắc tên để agent tự mở khi cần.
- **`CONTRACT.md`**: các quy ước mọi phần của hệ thống phải thống nhất (tên trạng thái, đường dẫn API, định dạng dữ liệu). Khi code và file này mâu thuẫn, file này đúng.
- **`SPEC.md`**: mô tả sản phẩm bằng một câu chuyện ván chơi, 3 luật không được phá, mục "cố ý không làm", cách tính điểm, giao diện, và bảng phân công file cho từng agent.
- **`STATE.md`**: tiến độ theo từng "sóng" (wave). Khi chạy đội, chỉ trưởng nhóm sửa file này để tránh ghi đè.

## Bắt đầu

### Yêu cầu

- Python 3.10+
- [Docker Desktop](https://www.docker.com/) (chạy suốt quá trình làm)
- [Claude Code](https://code.claude.com/docs)
- Tài khoản [OpenRouter](https://openrouter.ai/) và API key

### Cài đặt

```bash
git clone <link-repo-starter>
cp -r quizlive-starter ~/quizlive
cd ~/quizlive
```

Tạo file `.env` ở thư mục gốc (**không commit**, hãy chắc chắn `.env` nằm trong `.gitignore`):

```env
OPENROUTER_API_KEY=your_key_here
MODEL_NAME=your_model_name
QUESTION_SOURCE=mock          # mock khi test, llm khi chạy thật
PUBLIC_BASE_URL=http://localhost:8000
```

> Tên biến ở trên là ví dụ. Hãy đối chiếu với `planning/CONTRACT.md` và code trong repo của bạn.

### Chạy local bằng Docker

```bash
docker build -t quizlive .
docker run --rm -p 8000:8000 --env-file .env quizlive
```

Mở `http://localhost:8000`, tạo phòng, rồi mở thêm tab ẩn danh để đóng vai người chơi.

### Chạy test

```bash
# Chế độ mặc định: phần code chưa có thì test tự skip
pytest tests/invariants

# Chế độ bắt buộc: không được skip, code phải có và test phải xanh
# (tên biến môi trường xem trong CONTRACT.md)
REQUIRE_INVARIANTS=1 pytest tests/invariants
```

Dùng chế độ bắt buộc ở cuối để xác nhận đội agent thực sự làm xong, vì test bị skip trông giống như "không có lỗi" nhưng thực ra chưa kiểm tra gì.

## Quy trình theo video

1. **Setup**: clone starter, tạo `.env`, đọc `CLAUDE.md`, `CONTRACT.md`, `SPEC.md`, `STATE.md`.
2. **Viết và khóa test**: nhờ Claude viết 3 luật trong SPEC mục 2 thành test, đọc lời giải thích, duyệt, rồi khóa bằng `/permissions` (Deny cho Edit và Write trên `tests/invariants/**`).
3. **Sub-agent**: tạo `.claude/agents/leak-hunter.md` (chỉ quyền đọc và tìm, chạy model nhỏ).
4. **Agent Teams (demo)**: bật `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` trong `.claude/settings.json`, cho 3 agent tranh luận cách tính điểm, bạn là người quyết định.
5. **Hooks**: `Notification` (kêu khi Claude cần bạn) và `SessionStart` (in `STATE.md` vào context).
6. **Sandbox**: `/sandbox`, chọn chế độ BashTool với auto-allow. Thử lần lượt 3 lớp bảo vệ.
7. **Dựng phần nền** bằng một Claude duy nhất, rồi **chạy agent team** theo bảng phân công ở SPEC mục 8.
8. **Kiểm tra**: test chế độ bắt buộc, chạy `leak-hunter`, chơi thử trực tiếp.
9. **Deploy** lên Railway.

Nên commit và gắn tag sau mỗi bước để dễ theo dõi.

## 3 lớp bảo vệ file test

| Lớp | Chặn cái gì |
|---|---|
| Lời dặn trong `CLAUDE.md` | Claude bị yêu cầu sửa test thì từ chối |
| Deny rules trong `/permissions` | Công cụ sửa file của Claude |
| Sandbox | Lệnh terminal và script do Claude chạy |

Sandbox bọc các lệnh terminal, **không** bọc toàn bộ Claude Code. Công cụ đọc/sửa file của Claude đi qua hệ thống permissions. Hãy dùng cả hai. Nếu cần cô lập toàn bộ tiến trình (file tools, MCP, hooks), cần một ranh giới mạnh hơn như container hoặc máy ảo.

## Deploy lên Railway

1. Đăng ký tại [railway.com](https://railway.com), kết nối GitHub, chọn repo `quizlive`. Railway tự build từ Dockerfile.
2. Vào **Variables**, thêm các biến từ `.env` (API key, tên model, `QUESTION_SOURCE=llm`).
3. Vào **Settings, Networking, Generate Domain**.
4. Copy domain vừa tạo, dán vào biến `PUBLIC_BASE_URL`. Railway tự deploy lại.
5. Mở domain, tạo phòng, quét QR bằng điện thoại.

## Lưu ý quan trọng

- Agent Teams hiện là tính năng **thử nghiệm**, tốn nhiều token hơn (mỗi teammate là một phiên riêng). Tài liệu khuyến nghị bắt đầu với 3 đến 5 agent.
- Sub-agent tiết kiệm context nhưng chỉ trả về bản tóm tắt, có thể thiếu chi tiết bạn cần. Dùng cho việc đọc nhiều, kết luận ít.
- Đừng tạo hook cho mọi thứ. Chỉ dùng cho thao tác lặp lại, có quy tắc rõ ràng.
- Input chủ đề của người dùng được đưa vào prompt: đã giới hạn độ dài, bọc trong vùng phân định rõ, và nói với model đây là dữ liệu chứ không phải chỉ dẫn (xem SPEC).
- Dù dùng agent nào, **bạn vẫn là người chịu trách nhiệm** cho code mình giao đi.

## Tài liệu tham khảo

**Khái niệm agent và agentic loop**
- Simon Willison, *Designing agentic loops*: https://simonwillison.net/2025/Sep/30/designing-agentic-loops/

**Claude Code**
- Agent Teams: https://code.claude.com/docs/en/agent-teams
- Sandboxing: https://code.claude.com/docs/en/sandboxing
- Agent Teams và giao tiếp giữa các agent (bài hướng dẫn cộng đồng): https://claude-world.com/tutorials/s09-agent-teams-and-communication/

**An toàn AI**
- Anthropic và Accenture, embedded evaluation: https://www.anthropic.com/news/accenture-embedded-evaluation
- Dario Amodei, *We must pace the frontier*: https://darioamodei.com/post/we-must-pace-the-frontier

- Khoá học tham khảo: [AI Coder](https://www.udemy.com/course/ai-coder-from-vibe-coder-to-agentic-engineer/)

**Lưu ý: Toàn bộ những gì mình chia sẽ đều là những gì mình học và tổng hợp được. No COMMERCIAL intent!!**
