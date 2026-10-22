-- ==============================================================================
-- CareCycle Database Schema & Security Definition
-- PostgreSQL / Supabase
-- Desain Standar PostgreSQL: Kolom TEXT + CHECK Constraint (Bebas Masalah Enum)
-- ==============================================================================

-- 1. BERSIHKAN TABEL & TIPE LAMA SECARA BERSIH
DROP TABLE IF EXISTS public.campaign_pledges CASCADE;
DROP TABLE IF EXISTS public.campaigns CASCADE;
DROP TABLE IF EXISTS public.requests CASCADE;
DROP TABLE IF EXISTS public.items CASCADE;
DROP TABLE IF EXISTS public.communities CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS verification_status CASCADE;
DROP TYPE IF EXISTS item_status CASCADE;
DROP TYPE IF EXISTS request_status CASCADE;
DROP TYPE IF EXISTS delivery_method CASCADE;
DROP TYPE IF EXISTS campaign_status CASCADE;

-- 2. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 3. TABEL DEFINITION (DENGAN CHECK CONSTRAINTS)
-- ==============================================================================

-- Tabel Profiles (Relasi 1-to-1 dengan auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'donatur' CHECK (role IN ('donatur', 'komunitas', 'admin')),
    phone_number TEXT,
    address TEXT,
    care_points INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Tabel Communities (Data legalitas & verifikasi)
CREATE TABLE public.communities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    community_name TEXT NOT NULL,
    description TEXT,
    legal_document_url TEXT,
    verification_status TEXT NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Tabel Items (Katalog donasi barang)
CREATE TABLE public.items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    condition TEXT NOT NULL,
    photo_urls TEXT[] NOT NULL DEFAULT '{}',
    location TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'requested', 'processing', 'completed')),
    accepted_request_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Tabel Requests (Permintaan barang oleh Komunitas)
CREATE TABLE public.requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    community_id UUID NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'submitted' CHECK (status IN ('submitted', 'approved', 'rejected', 'received')),
    delivery_method TEXT CHECK (delivery_method IN ('courier', 'self_deliver', 'pickup')),
    tracking_number TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Foreign Key relasi accepted_request_id
ALTER TABLE public.items
    ADD CONSTRAINT fk_items_accepted_request
    FOREIGN KEY (accepted_request_id) REFERENCES public.requests(id) ON DELETE SET NULL;

-- Tabel Campaigns (Open Campaign oleh Komunitas)
CREATE TABLE public.campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    target_category TEXT NOT NULL,
    target_quantity INTEGER NOT NULL CHECK (target_quantity > 0),
    collected_quantity INTEGER NOT NULL DEFAULT 0 CHECK (collected_quantity >= 0),
    banner_url TEXT,
    end_date TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Tabel Campaign Pledges (Komitmen donasi dari Donatur)
CREATE TABLE public.campaign_pledges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
    donor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    notes TEXT,
    is_fulfilled BOOLEAN NOT NULL DEFAULT false,
    fulfilled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ==============================================================================
-- 4. FUNCTIONS & TRIGGERS
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_communities_updated_at BEFORE UPDATE ON public.communities
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_items_updated_at BEFORE UPDATE ON public.items
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_requests_updated_at BEFORE UPDATE ON public.requests
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_campaigns_updated_at BEFORE UPDATE ON public.campaigns
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_campaign_pledges_updated_at BEFORE UPDATE ON public.campaign_pledges
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger Auto-create Profile saat User Register di auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role_val TEXT := 'donatur';
    raw_role_str TEXT;
    community_name_val TEXT;
BEGIN
    raw_role_str := NEW.raw_user_meta_data->>'role';
    IF raw_role_str = 'komunitas' THEN
        user_role_val := 'komunitas';
    ELSIF raw_role_str = 'admin' THEN
        user_role_val := 'admin';
    ELSE
        user_role_val := 'donatur';
    END IF;

    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        user_role_val
    );

    IF user_role_val = 'komunitas' THEN
        community_name_val := COALESCE(NEW.raw_user_meta_data->>'community_name', NEW.raw_user_meta_data->>'full_name', 'Komunitas');
        INSERT INTO public.communities (profile_id, community_name, verification_status)
        VALUES (
            NEW.id,
            community_name_val,
            'pending'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.is_community_verified(target_profile_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.communities
        WHERE profile_id = target_profile_id
          AND verification_status = 'verified'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin(target_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = target_user_id
          AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_pledges ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Profil dapat dibaca oleh pengguna terautentikasi"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Pengguna dapat mengubah profil sendiri"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id OR public.is_admin(auth.uid()))
    WITH CHECK (auth.uid() = id OR public.is_admin(auth.uid()));

-- Communities Policies
CREATE POLICY "Profil komunitas dapat dibaca oleh pengguna terautentikasi"
    ON public.communities FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Komunitas dapat insert profil komunitas miliknya"
    ON public.communities FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Komunitas dapat memperbarui data komunitasnya sendiri"
    ON public.communities FOR UPDATE
    TO authenticated
    USING (auth.uid() = profile_id OR public.is_admin(auth.uid()))
    WITH CHECK (auth.uid() = profile_id OR public.is_admin(auth.uid()));

-- Items Policies
CREATE POLICY "Katalog item available dapat dibaca publik"
    ON public.items FOR SELECT
    TO public
    USING (
        status = 'available'
        OR auth.uid() = donor_id
        OR auth.uid() IS NOT NULL
    );

CREATE POLICY "Donatur dapat menambahkan item baru"
    ON public.items FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = donor_id);

CREATE POLICY "Donatur hanya mengubah item miliknya"
    ON public.items FOR UPDATE
    TO authenticated
    USING (auth.uid() = donor_id OR public.is_admin(auth.uid()))
    WITH CHECK (auth.uid() = donor_id OR public.is_admin(auth.uid()));

CREATE POLICY "Donatur hanya menghapus item miliknya"
    ON public.items FOR DELETE
    TO authenticated
    USING (auth.uid() = donor_id OR public.is_admin(auth.uid()));

-- Requests Policies (Hanya Komunitas Verified boleh request)
CREATE POLICY "Hanya komunitas verified yang boleh insert request"
    ON public.requests FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = community_id
              AND c.profile_id = auth.uid()
              AND c.verification_status = 'verified'
        )
    );

CREATE POLICY "Pihak terkait dapat membaca request"
    ON public.requests FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.items i
            WHERE i.id = item_id AND i.donor_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = community_id AND c.profile_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

CREATE POLICY "Pihak terkait dapat mengubah status request"
    ON public.requests FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.items i
            WHERE i.id = item_id AND i.donor_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = community_id AND c.profile_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

-- Campaigns Policies (Hanya Komunitas Verified boleh buat campaign)
CREATE POLICY "Campaign aktif dapat dibaca publik"
    ON public.campaigns FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Hanya komunitas verified yang boleh insert campaign"
    ON public.campaigns FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = community_id
              AND c.profile_id = auth.uid()
              AND c.verification_status = 'verified'
        )
    );

CREATE POLICY "Komunitas pembuat dapat mengupdate campaign"
    ON public.campaigns FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = community_id AND c.profile_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

-- Campaign Pledges Policies
CREATE POLICY "Donatur dan penyelenggara dapat membaca pledges"
    ON public.campaign_pledges FOR SELECT
    TO authenticated
    USING (
        donor_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.campaigns c
            JOIN public.communities com ON com.id = c.community_id
            WHERE c.id = campaign_id AND com.profile_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

CREATE POLICY "Donatur dapat memberikan komitmen pledge"
    ON public.campaign_pledges FOR INSERT
    TO authenticated
    WITH CHECK (donor_id = auth.uid());

CREATE POLICY "Pihak terkait dapat mengupdate pledge"
    ON public.campaign_pledges FOR UPDATE
    TO authenticated
    USING (
        donor_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.campaigns c
            JOIN public.communities com ON com.id = c.community_id
            WHERE c.id = campaign_id AND com.profile_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

-- ==============================================================================
-- 6. STORAGE BUCKETS & POLICIES
-- ==============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'item-photos',
    'item-photos',
    true,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'legal-docs',
    'legal-docs',
    false,
    10485760,
    ARRAY['application/pdf', 'image/jpeg', 'image/png']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Semua orang dapat melihat item-photos" ON storage.objects;
CREATE POLICY "Semua orang dapat melihat item-photos"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'item-photos');

DROP POLICY IF EXISTS "Pengguna login dapat upload ke item-photos" ON storage.objects;
CREATE POLICY "Pengguna login dapat upload ke item-photos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'item-photos');

DROP POLICY IF EXISTS "Pemilik dapat update foto item miliknya" ON storage.objects;
CREATE POLICY "Pemilik dapat update foto item miliknya"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (bucket_id = 'item-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Komunitas dan admin dapat membaca legal-docs" ON storage.objects;
CREATE POLICY "Komunitas dan admin dapat membaca legal-docs"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'legal-docs'
        AND (
            (storage.foldername(name))[1] = auth.uid()::text
            OR public.is_admin(auth.uid())
        )
    );

DROP POLICY IF EXISTS "Komunitas dapat upload legal-docs miliknya" ON storage.objects;
CREATE POLICY "Komunitas dapat upload legal-docs miliknya"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'legal-docs'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- ==============================================================================
-- 7. SUPABASE REALTIME REPLICATION
-- ==============================================================================

-- Aktifkan Realtime Replication untuk tabel items dan requests
ALTER PUBLICATION supabase_realtime ADD TABLE public.items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.requests;

